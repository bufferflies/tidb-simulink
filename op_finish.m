% Level-2 MATLAB file S-Function for unit delay demo.

%   Copyright 1990-2009 The MathWorks, Inc.
function op_finish(block)
% op finish 
setup(block);
%endfunction

function setup(block)

block.NumDialogPrms  = 1;

%% Register number of input and output ports
% in1: operator(srcID,dstID,regionID)
block.NumInputPorts  = 1;

% out1: diff leader 
% out2: diff place 
block.NumOutputPorts = 2;

%% Setup functional port properties to dynamically
%% inherited.
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(2).SamplingMode = 'Sample';

block.InputPort(1).Dimensions        = 4;
block.InputPort(1).DirectFeedthrough = false;

block.OutputPort(1).Dimensions       = block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2);
block.OutputPort(2).Dimensions       = block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2);

%% Set block sample time to [0.1 0] ，-1 inherit input
block.SampleTimes = [-1 0];

%% Set the block simStateCompliance to default (i.e., same as a built-in block)
block.SimStateCompliance = 'DefaultSimState';

%% Register methods
block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions',    @InitConditions);
block.RegBlockMethod('Outputs',                 @Output);
block.RegBlockMethod('Update',                  @Update);
block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode)
block.RegBlockMethod('SetInputPortDimensionsMode',  @SetInputDimsMode);

%endfunction

function DoPostPropSetup(block)

%% Setup Dwork
% Dwork(1): record diff leader
% Dwork(2): record diff place 
block.NumDworks = 2;
block.Dwork(1).Name = 'x0';
block.Dwork(1).Dimensions      = block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2);
block.Dwork(1).DatatypeID      = 0;
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = true;

block.Dwork(2).Name = 'x1';
block.Dwork(2).Dimensions      = block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2);
block.Dwork(2).DatatypeID      = 0;
block.Dwork(2).Complexity      = 'Real';
block.Dwork(2).UsedAsDiscState = true;


%endfunction

function InitConditions(block)

%% Initialize Dwork
block.Dwork(1).Data = zeros(1,block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2));
block.Dwork(2).Data = zeros(1,block.DialogPrm(1).Data(1)*block.DialogPrm(1).Data(2));
%endfunction

function Output(block)
block.OutputPort(1).Data =  block.Dwork(1).Data;
block.OutputPort(2).Data =  block.Dwork(2).Data;

%endfunction
function Update(block)
region_count=block.DialogPrm(1).Data(1);
% store_count=block.DialogPrm(1).Data(2);
operator=block.InputPort(1).Data;
if operator(1)<=0
    return
end
srcID=operator(1);
dstID=operator(2);
regionID=operator(3);
idx=(srcID-1)*region_count+regionID;
block.Dwork(1).Data(idx)=block.Dwork(1).Data(idx)-1;
idx=(dstID-1)*region_count+regionID;
block.Dwork(1).Data(idx)=block.Dwork(1).Data(idx)+1;

%  move peer
if operator(4)==2
idx=(srcID-1)*region_count+regionID;
block.Dwork(2).Data(idx)=block.Dwork(2).Data(idx)-1;
idx=(dstID-1)*region_count+regionID;
block.Dwork(2).Data(idx)=block.Dwork(2).Data(idx)+1;
end 
%endfunction

function SetInputPortSamplingMode(block, idx, fd)
block.InputPort(idx).SamplingMode = fd;
block.OutputPort(1).SamplingMode = fd;

