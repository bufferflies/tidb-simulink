function rate_limit(block)
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
  % in3: take 
  block.NumInputPorts  = 3;
  
  % out1: pop
  % out2: size 
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
  block.InputPort(3).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = 1;
  block.OutputPort(2).Dimensions       = 1;
  
  %% Set block sample time to [0.1 0]
  block.SampleTimes = [block.DialogPrm(1).Data(2) 0];
  
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
  block.Dwork(1).Dimensions      = block.DialogPrm(1).Data(1)*100;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  %% Dwork(2): record variable

  block.Dwork(2).Name = 'x1'; 
  block.Dwork(2).Dimensions      = 6;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  % Dwork(2).Data(1): start
  % Dwork(2).Data(2): end
  % Dwork(2).Data(3): last insert time   
  % Dwork(2).Data(4): queue capacity  
  % Dwork(2).Data(5): rate/sec
  % Dwork(2).Data(6): last_stop
  % we consumer the queue is large     
  block.Dwork(1).Data = zeros(1,block.DialogPrm(1).Data(1)*100);
  block.Dwork(2).Data = ones(1,6);
  block.Dwork(2).Data(3)=0;
  block.Dwork(2).Data(4)=block.DialogPrm(1).Data(1);
  block.Dwork(2).Data(5)=block.DialogPrm(1).Data(1)/60;
  block.Dwork(2).Data(6)=1;
%endfunction

function Output(block)
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  
  take=block.InputPort(3).Data;
  store_limit=block.DialogPrm(1).Data(1);
  out=0;
  for i = 1: take
    if start>=stop
        break
    end
    if  block.Dwork(1).Data(mod(start,store_limit*100)+1)>0
        out=out+1;
    else
        out=out-1;
    end
    block.Dwork(1).Data(mod(start,store_limit*100)+1)=0;  
    start=start+1;
  end
  
  block.OutputPort(1).Data = out;
  block.OutputPort(2).Data = stop-start;
  block.Dwork(2).Data(1)=start;
  
%endfunction

function Update(block)
  last_stop= block.Dwork(2).Data(6);
  ops=block.InputPort(1).Data;
  time=block.InputPort(2).Data;
  store_limit=block.DialogPrm(1).Data(1);
  if ops==0
    return 
  end
  last_time=block.Dwork(2).Data(3);
  capacity=block.Dwork(2).Data(4);
  rate = block.Dwork(2).Data(5);
  start=block.Dwork(2).Data(1);
  stop=block.Dwork(2).Data(2);
  
  if time-last_time>=1
    incr=rate*(time-last_time);
    capacity=capacity-(stop-last_stop)+incr;
    block.Dwork(2).Data(4)=min(capacity,block.DialogPrm(1).Data(1));
    block.Dwork(2).Data(3)=time;
    block.Dwork(2).Data(6)=stop;
    last_stop=stop;
  end
 
  for i=1:abs(ops)
    if (stop-start>=store_limit*100)||(stop-last_stop>=capacity)
        break 
    end 
    if ops>0
        block.Dwork(1).Data(mod(stop,store_limit*100)+1)=1;
    else
        block.Dwork(1).Data(mod(stop,store_limit*100)+1)=-1;
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
%endfunction


