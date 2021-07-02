function max_filter(block)
% Level-2 MATLAB file S-Function for unit delay demo.

%   Copyright 1990-2009 The MathWorks, Inc.

  setup(block);
  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 1;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = 1;
  
  %% Set block sample time to [0.1 0]
  block.SampleTimes = [block.DialogPrm(1).Data(2) 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 2;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = block.DialogPrm(1).Data(1);
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name = 'x1'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  block.Dwork(1).Data = zeros(1,block.DialogPrm(1).Data(1));
  block.Dwork(2).Data = 0;
  
%endfunction

function Output(block)

  block.OutputPort(1).Data =  max(block.Dwork(1).Data);
  
%endfunction

function Update(block)

  count=block.Dwork(2).Data(1);
  size=block.DialogPrm(1).Data(1);
  index=mod(count,size)+1;
  block.Dwork(1).Data(index) = block.InputPort(1).Data;
  block.Dwork(2).Data=block.Dwork(2).Data+1;
  
%endfunction

