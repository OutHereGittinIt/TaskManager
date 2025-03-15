function QuickHighlight(tx_obj,f,varargin)
%
% Call Attention to uilabel Object By Fading and Relighting Background Clr
%
% David Richardson
% 12/18/2023

PI = parse_inputs(tx_obj,f,varargin{:});
PI = PI.Results;

switch PI.time_type
    case 'total'
        time_period = PI.time_input/PI.num_it;
    case 'period' 
        time_period = PI.time_input;
    otherwise
        error('Wrong time input. Use "total" or "per_it" for per iteration')
end

% create timer
t = timer;
t.Period            = time_period;
t.TimerFcn          = @(T,~)raise_tx_clr(PI,f,T);
t.StopFcn           = @(T,~)stop_fcn(T);
t.ExecutionMode     = "fixedRate";
t.TasksToExecute    = PI.num_it;

t.UserData.it_count = 1;
t.UserData.Text_W2B = linspace(1,0,PI.num_it).*[1;1;1];

start(t)
wait(t)
end

function PI = parse_inputs(tx_obj,f,varargin)
%% Parse inputs

PI = inputParser;

max_dim     = .7;
num_it      = 50;
time_input  = 1.75;     % seconds
time_type   = 'total';  % or 'period'
w2b_flag    = false;    % word to background font change

addRequired(PI,'tx_obj')
addRequired(PI,'f')
addParameter(PI,'max_dim',max_dim)
addParameter(PI,'num_it',num_it)
addParameter(PI,'time_input',time_input)
addParameter(PI,'time_type',time_type)
addParameter(PI,'w2b_flag',w2b_flag)

parse(PI,tx_obj,f,varargin{:})
end

function raise_tx_clr(PI,f,t)
%% Iterate color change back to color background
it_count = t.UserData.it_count;

PI.tx_obj.BackgroundColor = f.Color * (PI.max_dim + (1-PI.max_dim)*(it_count - 1)/(PI.num_it - 1));

if PI.w2b_flag
    PI.tx_obj.FontColor = t.UserData.Text_W2B(:,it_count);
end

t.UserData.it_count = it_count +1;
end

function stop_fcn(T)
%% Not sure why have to do this
T.UserData.it_count = 1;
end