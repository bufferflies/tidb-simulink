function op_influence(block)
% Level-2 MATLAB file S-Function for unit delay demo.

%   Copyright 1990-2009 The MathWorks, Inc.

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 2;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(2).SamplingMode = 'Sample';
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  block.InputPort(2).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = 1;
  block.OutputPort(2).Dimensions       = 1;
  
  %% Set block sample time to [0.1 0]
  block.SampleTimes = [0.1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update); 
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode)
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 2;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = block.DialogPrm(1).Data(1);
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  %% start end 
  block.Dwork(2).Name = 'x1'; 
  block.Dwork(2).Dimensions      = 2;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  block.Dwork(1).Data = zeros(1,block.DialogPrm(1).Data(1));
  block.Dwork(2).Data = ones(1,2);
  
%endfunction

function Output(block)

  
  t=block.InputPort(2).Data*1000;  
  a=find(block.Dwork(1).Data<(t-block.DialogPrm(1).Data(2))&block.Dwork(1).Data~=0);
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  store_limit=block.DialogPrm(1).Data(1);
  for i = 1: size(a,1)
    block.Dwork(1).Data(mod(start,store_limit)+1)=0;  
    start=start+1;
  end
  
  block.OutputPort(1).Data = size(a,1);
  block.OutputPort(2).Data = stop-start;
  block.Dwork(2).Data(1)=start;
  
%endfunction

function Update(block)
  ops=block.InputPort(1).Data;
  if ops==0
    return 
  end
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  time=block.InputPort(2).Data*1000;
  store_limit=block.DialogPrm(1).Data(1);
  for i=1:ops
    if stop-start>store_limit-1
        return 
    end 
    block.Dwork(1).Data(mod(stop,store_limit)+1)=time;
    stop=stop+1;
  end 
  block.Dwork(2).Data(2)=stop;
 
  
%endfunction

function SetInputPortSamplingMode(block, idx, fd)
    block.InputPort(idx).SamplingMode = fd;
    block.InputPort(idx).SamplingMode = fd;

    block.OutputPort(1).SamplingMode = fd;
    block.OutputPort(2).SamplingMode = fd;
%endfunction


