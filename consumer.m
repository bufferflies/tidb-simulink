function consumer(block)
% Level-2 MATLAB file S-Function for unit delay demo.

%   Copyright 1990-2009 The MathWorks, Inc.

% rate limit
  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  % in1: input
  % in2: clock
  block.NumInputPorts  = 2;
  
  % out1: finish
  % out2: take
  % out3: size   
  block.NumOutputPorts = 3;

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
  block.OutputPort(3).Dimensions       = 1;
  %% Set block sample time to [0.1 0]
  block.SampleTimes = [block.DialogPrm(1).Data(3) 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update); 
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode)
  
%endfunction

%% DialogPrm(1).Data(1): store_limit
function DoPostPropSetup(block)

  %% Setup Dwork 
  % Dwork(1): record OP 
  block.NumDworks = 2;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = block.DialogPrm(1).Data(1);
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  %% Dwork(2): record variable
  block.Dwork(2).Name = 'x1'; 
  block.Dwork(2).Dimensions      = 2;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  block.Dwork(1).Data = -1e7*ones(1,block.DialogPrm(1).Data(1));
  % Dwork(2).Data(1): start
  % Dwork(2).Data(2): end
  block.Dwork(2).Data = ones(1,2);

%endfunction

function Output(block)
  t=block.InputPort(2).Data;
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  store_limit=block.DialogPrm(1).Data(1);
  a=find(abs(block.Dwork(1).Data)<(t-block.DialogPrm(1).Data(2))&block.Dwork(1).Data~=-1e7);
  out=0;
  for i = 1: size(a,1)
    if start>=stop
        break
    end
    if block.Dwork(1).Data(a(i))>0
        out=out+1;
    else
        out=out-1;
    end
    block.Dwork(1).Data(mod(start,store_limit)+1)=-1e7;  
    start=start+1;
  end
  influence=0;
  for i=start:stop-1
    if block.Dwork(1).Data(mod(i,store_limit)+1)>0
        influence=influence+1;
    else
        influence=influence-1;
    end
  end
    
  block.OutputPort(1).Data = out;
  block.OutputPort(2).Data = store_limit-(stop-start);
  block.OutputPort(3).Data = influence;
  block.Dwork(2).Data(1)=start;
  
%endfunction

function Update(block)
  time=block.InputPort(2).Data;
  ops=block.InputPort(1).Data;
  store_limit=block.DialogPrm(1).Data(1);
  if ops==0
    return 
  end
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  for i=1:abs(ops)
    if stop-start>store_limit
        return 
    end
    if ops>0
         block.Dwork(1).Data(mod(stop,store_limit)+1)=time;
    else
         block.Dwork(1).Data(mod(stop,store_limit)+1)=-time;
    end
   
    stop=stop+1;
  end 
  block.Dwork(2).Data(2)=stop;
  
%endfunction

function SetInputPortSamplingMode(block, idx, fd)
    block.InputPort(idx).SamplingMode = fd;
    block.InputPort(idx).SamplingMode = fd;
    block.OutputPort(1).SamplingMode = fd;
    block.OutputPort(2).SamplingMode = fd;
    block.OutputPort(3).SamplingMode = fd;
%endfunction


