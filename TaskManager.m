function TaskManager
%
% Record Tasks and Manage Status
%
% David Richardson
% 11/11/2023

%% Questions

% - f.Pointer is not working properly!! have to move mouse to go back to
% arrow. This is a very bad look, cant find anything online.

%% When to autosave -- Feel free to modify

% - new task                Done
% - completion              Done
% - deletion                Done
% - comment edit            Done
% - edit task               Done    
% - new display setting     Done
% - undo                    Done

%% Options 
% ~~~ add descriptors 

% ~~~ really, if an item is not repeated, or especially if it is only used
% for a specific subGUI, it should not be here. Can be moved here later as
% needed. But it would be good to clean this up.
% ^ This idea needs a little more thought. Long term 
%*  edit colors subfigure (move)
%** draw task 

% ~~~ My casing use here is wildly inconsistent, but such is life. Maybe fix

% independent options :

opts.ban_h          = 33; % banner height
opts.ban_fs         = 21; % banner font size
opts.btn_h_s        = 19; % button height (small)
opts.btn_h          = 22; % button height
opts.btn_h_l        = 26; % button height (large)
opts.btn_h_xl       = 32;
opts.btn_w_s        = 70;
opts.btn_w          = 90;
opts.btn_w_l        = 120;
opts.chkbx_w        = 150;
opts.clr_name_w     = 70; %*
opts.clr_h          = 33; %*
opts.clr_fs         = 16; %*
opts.collapse_sz    = 17;
opts.data_filename  = 'TaskManager_User_Data.mat';
opts.DateFormat     = 'MM/dd/uuuu';
opts.date_lbl_w     = 135; %**'Autosave Label'
opts.default_fname  = 'MyTasks'; % ~~~ kinda silly, tbh
opts.DefaultDurVal  = '3';
opts.DefaultDurStr  = 'Days';
opts.desc_w         = 400; % Task description width in add task GUI
opts.dpw            = 125; % uidatepicker width
opts.dr_lbl_w       = 50;
opts.dr_w           = 145;
opts.duedate_tx_w   = 75;
opts.DurationItems  = {'Hours','Days','Weeks','Months','Years'};
opts.dur_w          = 70;
opts.dur_w_l        = 85; %*
opts.ext            = '_TM.mat';
opts.fs             = 13; %**
opts.icon_sz        = 22;
opts.lbl_clr        = .91*[1,1,1];
opts.lbl_h          = 16;
opts.lbl_w          = 110; % Standard label width
opts.max_num_tasks  = 200;
opts.num_add_tasks  = 5; 
opts.num_w          = 20;
opts.num_w_l        = 28; %*
opts.num_w_xl       = 48; %*
opts.num_h_l        = 24.5; %*
opts.OptionalFields = {'Due Date','Type','Regularity','Completion Date','Creation Date'};
opts.pgb_min        = 10; % minimum number of task drawings for progress bar appearance
opts.priority_btn_w = 32;
opts.rgb_int_round  = 3; 
opts.screen_height_ratio = .8;
opts.scrollbar_w    = 12;
opts.spacer         = 5;
opts.show_lbl_clr   = false;
opts.tab_w          = 30; %**
opts.task_pan_clr   = [.92,.93,.99];
opts.task_pan_w     = 750;
opts.title_fs       = 22;
opts.tx_h           = 16; % height of common text labels
opts.type_lbl_w     = 95; %**

% optional fields conditional terms (see opts.OptionalFields for indexing)
opts.OptionalFieldsConditions = {...
    @(Task) strcmp(Task.Type,'Ongoing') || ~Task.Completed,...
    @(Task) true,...
    @(Task) strcmp(Task.Type,'Ongoing'),...
    @(Task) Task.Completed,...
    @(Task) true,...
    };

% Default settings :

opts.DefaultSettings.Autosave               = true;
opts.DefaultSettings.complete_clr           = [.8,1,.8];
opts.DefaultSettings.CompletionMode         = 'by subtask';
opts.DefaultSettings.AutoSetPriority        = true;
opts.DefaultSettings.default_clr            = [.85,.7,.71];
opts.DefaultSettings.deleted_clr            = [.82,.82,.82];
opts.DefaultSettings.folder_clr             = [.98,.96,.65];
opts.DefaultSettings.incomplete_clr         = [.89,.68,.49];
opts.DefaultSettings.Limits                 = DefaultLimits;
opts.DefaultSettings.pastdue_clr            = [250,240,238]/255;
opts.DefaultSettings.DescFontWeight         = 'normal';
opts.DefaultSettings.RankBy                 = 'Due Date';
opts.DefaultSettings.Show.Completed         = true;
opts.DefaultSettings.Show.Deleted           = false;
opts.DefaultSettings.Show.PastDue           = true;
opts.DefaultSettings.Show.CompletionDate    = true;
opts.DefaultSettings.Show.CreationDate      = true; 
opts.DefaultSettings.Show.DueDate           = true;
opts.DefaultSettings.Show.Regularity        = false;
opts.DefaultSettings.Show.Type              = false;

num_btns = add_fig_btns([],[],'Read only');

% dependent option(s) calculations :

% left panels (buttons panel, options panel)
btn_pan_w       = opts.btn_w_l;
opts_pan_w      = opts.dr_lbl_w + opts.dr_w + opts.spacer;
opts.left_pan_w = max([btn_pan_w,opts_pan_w]) + 3*opts.spacer;

% title panel height
opts.title_pan_h = 3*opts.tx_h + opts.btn_h_xl + 5*opts.spacer;

% button panel height
opts.btn_pan_h  = num_btns * (opts.spacer + opts.btn_h_l) + opts.spacer;

% options panel height
opts.opts_pan_h = 6*opts.btn_h + 7 *opts.spacer;

% stat panel height
opts.stat_pan_h = 7*opts.tx_h + 8*opts.spacer;

% figure size
opts.fig_w = opts.left_pan_w + opts.task_pan_w + 3 * opts.spacer;
if groot().MonitorPositions(4) == 1
    % not sure why this happens, but it did.
    opts.fig_h = 800;
else
    opts.fig_h = groot().MonitorPositions(4) * opts.screen_height_ratio;
end

% task panel height
opts.task_pan_h = opts.fig_h - opts.title_pan_h - 2*opts.spacer;

% duration string (value, name combination)
opts.duration_w = opts.num_w_l + opts.dur_w_l;

% folder naming
opts.folder         = fileparts(mfilename("fullpath"));
opts.data_filename  = fullfile(opts.folder,opts.data_filename);
opts.manager_loc    = fullfile(opts.folder,'Managers');
if ~isfolder(opts.manager_loc)
    mkdir(opts.manager_loc)
end

% X-position of color objects in 'Colors' settings option
opts.color_objects_x0 = opts.clr_name_w + opts.duration_w + 4*opts.spacer;

% X-position of delete/add icon objects in 'Colors' settings option
opts.icon_objects_x0 = opts.color_objects_x0 + opts.clr_h + 4*opts.spacer...
    + 3*(opts.num_w + opts.num_w_xl + opts.spacer);

% X-Position of priority mover buttons 
opts.mover_xpos = opts.task_pan_w - opts.spacer - opts.priority_btn_w - opts.scrollbar_w;

%% Main

% add paths as necessary
p = genpath(opts.folder);
addpath(p)

dbstop if error
disp('launching Task Manager Main Menu...')
MainMenu(opts)
end

function MainMenu(opts)
%% Main Menu upon starting application to create new or load

% options :
% (note: These are not in opts struct because they are only used here. It
% seems obvious *enough* to look to this function to modify these options.
% I think this is the right way to do this, therefore)
file_btn_w      = 160;
load_btn_w      = 40;
create_btn_w    = 85;
prev_load_w     = 98;
max_prev_load   = 4;
banner_w        = 245;
banner_fs       = 18;
banner_h        = 30;
banner_txt      = 'Task Management Application';
spacer_l        = opts.spacer * 3;

% dependent options
width   = prev_load_w + max_prev_load*file_btn_w + (max_prev_load+2)*opts.spacer;
height  = banner_h + 2*opts.btn_h + 3*opts.spacer + spacer_l;
ban_space = (width - banner_w)/2;
btn_space = (width - create_btn_w - load_btn_w)/3;

% create figure
f = uifigure("Name",'Main Menu','Pointer','watch');
f.Position(3:4) = [width,height];
centerfig(f)

% add banner
banner_ypos = height - opts.spacer - banner_h;
uilabel(f,'Text',banner_txt,'FontSize',banner_fs,...
    'Position',[ban_space,banner_ypos,banner_w,banner_h],...
    'HorizontalAlignment','center');

% add create vs load option
ypos = banner_ypos - opts.spacer - opts.btn_h;
uibutton(f,'Text','Create New','FontSize',opts.fs,...
    'Position',[btn_space,ypos,create_btn_w,opts.btn_h],...
    'ButtonPushedFcn',@(btn,~)prompt_new_task_manager(f,btn,opts),...
    'VerticalAlignment','center');
uibutton(f,'Text','Load','FontSize',opts.fs,...
    'Position',[2*btn_space + create_btn_w,ypos,load_btn_w,opts.btn_h],...
    'ButtonPushedFcn',@(~,~)load_task_manager(opts,f),...
    'VerticalAlignment','center');

% add previously loaded section
if exist(opts.data_filename,'file')
    warning off
    load(opts.data_filename,'LoadedList')
    warning on
    if exist('LoadedList','var') && ~isempty(LoadedList)
        % ~~~ should this be a panel? decide later
        uilabel(f,"Text",'Recently loaded:','FontSize',opts.fs,...
            'Position',[opts.spacer,opts.spacer,prev_load_w,opts.btn_h]);
        % Create prev. load buttons
        counter = 0;
        xpos = 2*opts.spacer + prev_load_w;
        for i = 1:numel(LoadedList)
            if exist(fullfile(opts.manager_loc,LoadedList{i}),'file')
                % create load button for previously loaded files
                uibutton(f,'Text',LoadedList{i},'FontSize',opts.fs,...
                    'Position',[xpos,opts.spacer,file_btn_w,opts.btn_h],...
                    'ButtonPushedFcn',@(btn,~)load_task_manager(opts,f,btn),...
                    'VerticalAlignment','center');

                xpos = xpos + opts.spacer + file_btn_w;

                % max number to display
                counter = counter + 1;
                if counter == max_prev_load
                    break
                end
            end
        end
    end
else
    LoadedList = {};
    save(opts.data_filename,"LoadedList")
end

f.Pointer = 'arrow';
end

function prompt_new_task_manager(f,btn,opts)
%% Prompt name for new task manager on Main Menu figure
 
f.Pointer = 'watch';drawnow

% Options 
tx_w = 110;
lbl_w = 65;
ext_w = 52.5;
start_w = 40;

% idea is to delete button and replace with file name prompt
xpos = btn.Position(1);
ypos = btn.Position(2);
delete(btn)

% label
lbl_xpos = xpos - lbl_w;
uilabel(f,'Text','File name:','Position',[lbl_xpos,ypos,lbl_w,opts.btn_h],...
    'FontSize',opts.fs);

% textarea
t = uitextarea(f,"Value",new_filename(opts),'FontSize',12,...
    'Position',[xpos,ypos,tx_w,opts.btn_h]);

% file extension
ext_xpos = xpos + tx_w + opts.spacer;
uilabel(f,'Text',opts.ext,'FontSize',opts.fs,...
    'Position',[ext_xpos,ypos,ext_w,opts.btn_h]);

% Start Button
start_xpos = ext_xpos + ext_w + opts.spacer;
uibutton(f,'Text','Start','FontSize',opts.fs,...
    'Position',[start_xpos,ypos,start_w,opts.btn_h],...
    'ButtonPushedFcn',@(~,~)create_new_task_manager(f,t,opts));

f.Pointer = 'arrow';
end

function filename = new_filename(opts)
%% Return new & unused default filename for new task manager
good_name   = false;
counter     = 1;
max_counter = 50;
while ~good_name
    filename = [opts.default_fname,num2str(counter)]; 
    if ~exist(fullfile(opts.manager_loc,[filename,'_TM.mat']),'file')
        good_name = true;
    else 
        counter = counter + 1;
    end
    % Prevent infinite loop (just in case)
    if counter > max_counter
        error("Too many of these files, or infinite loop error. Either way, please attend to")
    end
end
end

function create_new_task_manager(f,t,opts)
%% Start New Task Manager 

fname = t.Value{1};
delete(f)

f = create_figure(opts,fname);
f.Pointer = 'watch';drawnow

% New figure initialize userdata :
f.UserData.Name = [fname,opts.ext];

% Empty task set with example task
f.UserData.NumTasks = 0;
f.UserData.Tasks(opts.max_num_tasks,1) = empty_task(opts.max_num_tasks);

% no default due date as default (not modifiable by UserData)
f.UserData.DefaultDueDate = 'N/A';

% no unsaved changes yet
f.UserData.UnsavedChangesPresent = false;

% Load defualt settings from file (if saved) or default default settings (default inception lol,maybe describe this better)
set_default_settings(f,opts)

% Store for previous ('undo') functionality
f.UserData.Old  = f.UserData; % ~~~ is this necessary here???

% Save to new file
UserData        = f.UserData;
fullfilename    = fullfile(opts.manager_loc,f.UserData.Name);
filename        = f.UserData.Name;
save(fullfilename,'UserData')

% Add to previously loaded list (and save)
warning off
load(opts.data_filename,'LoadedList')
LoadedList = [{filename},LoadedList];
LoadedList = unique(LoadedList,'stable');
save(opts.data_filename,"LoadedList",'-append')
warning on

% draw it
draw_figure(f,opts)
centerfig(f)
f.Pointer = 'arrow';
end

function f = create_figure(opts,name)
%% Create Task Manager parent figure (shared among create new and load)

% The reason we do it this way is becuase it is not reccomended to save
% a figure object. So we can save and load user data struct but we need to
% create figure with attributes upon opening app every time

f = uifigure('Name',[name,' Task Manager'],'Resize',false);
f.Position(3:4) = [opts.fig_w,opts.fig_h];
centerfig(f)

% close request fcn
f.CloseRequestFcn = @(self,~) exit_task_manager(self,opts);
end

function ExampleTask = empty_task(example_task_ind)
%% Return example task to initialize proper struct fields in Tasks struct array and for displaying while modifying settings

% Create example task
ExampleTask.Name                = 'Example Task';
ExampleTask.Type                = 'One time event';

% New task attributes (non-contingent) :
ExampleTask.Color               = [];
ExampleTask.Collapsed           = false;
ExampleTask.Collapsing          = false;
ExampleTask.Comment             = '';
ExampleTask.Completed           = false;
ExampleTask.CompletionDate      = NaT;
ExampleTask.CreationDate        = datetime;
ExampleTask.Deleted             = false; 
ExampleTask.DueDateRank         = [];
ExampleTask.isFolder            = false;
ExampleTask.isOriginal          = true;
ExampleTask.PastDue             = false;
ExampleTask.ParentTask          = [];
ExampleTask.Priority            = example_task_ind; % ~~~ does this make sense?? I dont think it does
ExampleTask.PriorityBtnYPos     = []; 
ExampleTask.SubTasks            = [];
ExampleTask.xpos                = [];
ExampleTask.ypos                = [];

% Task layout vars (this is one reason why it would('ve) been good to group
% these variables into one mid-level struct, but this is ok too)
ExampleTask.Show.DueDate        = [];
ExampleTask.Show.Type           = [];
ExampleTask.Show.Regularity     = [];
ExampleTask.Show.CompletionDate = [];
ExampleTask.Show.CreationDate   = [];
ExampleTask.DueDateHeight       = [];
ExampleTask.TypeHeight          = [];
ExampleTask.RegularityHeight    = [];
ExampleTask.CompletionDateHeight= [];
ExampleTask.CreationDateHeight  = [];
ExampleTask.Height              = [];
ExampleTask.Width               = [];

ExampleTask.DueDate        = 'N/A';
ExampleTask.DurationStr    = 'N/A';
ExampleTask.DurationVal    = 'N/A';

ExampleTask.Labels = [];

ExampleTask.isDrawn = false;
end

function Limits = DefaultLimits
%% Default ranking and colors for task priority

Limits(1).DurationVal   = '3';
Limits(1).DurationStr   = 'Days';
Limits(1).Color         = [1,.7,.7];

Limits(2).DurationVal   = '1';
Limits(2).DurationStr   = 'Weeks'; 
Limits(2).Color         = [1.0000    0.85    0.8];

Limits(3).DurationVal   = '2';
Limits(3).DurationStr   = 'Weeks';
Limits(3).Color         = [0.8510    0.6    0.380];
end

function read_duration_limits(f)
%% Read user-set or default urgency level limits and corresponding colors

% Ranking:(f.UserData.RankBy = 'Urgency')
%   -  With due date, ranked for how soon by user-editable limits
%       - (^ this has size =    length(Limits) + 1)    
%   -  No due date, incomplete  length(Limits) + 2
%   -  No due date, complete    length(Limits) + 3
% Create Ranking from Limits

Limits          = f.UserData.Limits; % brevity
num             = numel(Limits);
DurationLimits  = repmat(days([]),num,1);
for i = 1:num
    DurationLimits(i) = read_duration(Limits(i));
end

% Make sure durations are in correoct order
[DurationLimits, LimitOrder]    = sort(DurationLimits);
f.UserData.Limits               = Limits(LimitOrder);
f.UserData.DurationLimits       = DurationLimits;
end

function load_task_manager(opts,f,btn)
%% prompt uigetfile to Load task manager

if exist('btn','var')
    filename = btn.Text;
else
    filename = uigetfile([opts.manager_loc,'/*',opts.ext]);
    if filename == 0
        return
    end
end

% delete main menu (~~~ could do this in wrapper? or unnecessary)
if exist('f','var')
    delete(f)
end

% delete current figure, create new
% delete(f) ~~~ decided not to delete old figure
f = create_figure(opts,filename);

% load UserData and check for / fix compatability!
load(fullfile(opts.manager_loc,filename),'UserData')
if ~isfield(UserData,'CompatabilityVerified')...
        || ~isequal(UserData.CompatabilityVerified,'5/27/2025')
    UserData = update_task_manager_compatibility(UserData,opts);
    % save compatability update for this file
    save(fullfile(opts.manager_loc,filename),'UserData')
end

f.UserData  = UserData;
f.Pointer   = 'watch';drawnow

% Add to loaded list data
load(opts.data_filename,'LoadedList')
if exist('LoadedList','var')
    LoadedList = [{filename},LoadedList];
    LoadedList = unique(LoadedList,'stable');
else
    LoadedList = {filename};
end
save(opts.data_filename,"LoadedList",'-append')

% draw figure base don loaded userdata
draw_figure(f,opts)
f.Pointer   = 'arrow';drawnow
end

function draw_figure(f,opts)
%% Draw All Elements of the uifigure

% start from top
f.UserData.y0 = opts.fig_h;

add_title_panel(f,opts)

add_statistics_panel(f,opts)

add_fig_btns(f,opts);

add_options_panel(f,opts)

add_tasks_panel(f,opts)

% remove vertical position counter
f.UserData = rmfield(f.UserData,'y0');

focus(f)
end

function add_title_panel(f,opts)
%% Draw Title Banner for Figure

% add panel 
f.UserData.y0 = f.UserData.y0 - opts.title_pan_h;
p = uipanel(f,'Position',[opts.spacer,f.UserData.y0,opts.fig_w - 2*opts.spacer,opts.title_pan_h]);

% add title
ypos = 3*opts.tx_h + 4*opts.spacer;
uilabel(p,'Text',f.Name,'FontSize',opts.title_fs,'FontColor',[0 0 1],...
    'Position',[opts.spacer,ypos,opts.fig_w - 2*opts.spacer,opts.btn_h_xl]);

% add autosave lable & switch 
lbl_w = 90;
ypos = 2*opts.tx_h + 3*opts.spacer;
uilabel(p,'Text','Autosave mode:','Position',[opts.spacer,ypos,lbl_w,opts.tx_h]);

if f.UserData.Autosave
    mode = 'On';
else
    mode = 'Off';
end
uisw = uiswitch(p,'Items',{'Off','On'},'Value',mode,'ValueChangedFcn',@(self,~)autosave_warning(self,f));
pause(1)
d_out_in = uisw.InnerPosition(1) - uisw.OuterPosition(1);
uisw.Position = [d_out_in + opts.spacer + lbl_w,ypos,200,opts.tx_h];

% add autosave label
l = uilabel(p,'Text',autosave_str,...
    'Position',[opts.spacer,opts.spacer,200,opts.tx_h],...
    'Tag','Autosave Label','VerticalAlignment','bottom'); 
l.UserData.tmr = [];

% ~~~ this displays a new save date without actually saving. needs 
% autosave(f,opts,'manual')
% ^ but actually, in what case would you need to save here? Does it matter
% if that time is technically incorrect? idk

% add default due date label and textarea (start disabled)
ypos = ypos - opts.spacer - opts.tx_h;
lbl_w = 160;
lab_pos = [opts.spacer,ypos,lbl_w,opts.tx_h];
uilabel(p,"Text",'Default Manager Due Date: ','Position',lab_pos);

txarea_pos = [opts.spacer + lbl_w,ypos,opts.duedate_tx_w,opts.btn_h_s];
uitextarea(p,'Position',txarea_pos,'Value',f.UserData.DefaultDueDate,...
    'ValueChangedFcn',@(self,~)set_default_duedate(f,self));
end

function str = autosave_str
%% Return string to reflect current date for autosave string
str = ['Saved ',char(datetime,'MM/dd/uuuu hh:mm a')];
end

function num_btns = add_fig_btns(f,opts,ReadMode) %#ok<INUSD>
%% Add Buttons to Figure 

% Button data
Text        = ["Add Task","Add Folder","Undo","Save Manager","New Manager","Load Manager","Settings","Activity Monitor"];
Shortcut    = ["t","f","z","s","n","o","p","a"];
Icon        = ["plus.png","folder.jpg","Undo.jpg","save.jpg","notes.jpg","download.png","settings.png","look.jpg"];
CallBack    = { @(~,~)add_task_gui(f,[],opts,'new task'),...
                @(~,~)add_task_gui(f,[],opts,'new folder'),...
                @(~,~)restore_previous_tasks(f,opts),...
                @(~,~)autosave_tasks(f,opts,'manual'),...
                @(~,~)MainMenu(opts),...
                @(~,~)load_task_manager(opts),...
                @(~,~)disp_settings(f,opts),...
                @(~,~)show_recent_activity(f,opts)};

% size error check
num_btns    = numel(Text);

% return number of buttons for positioning calculations (read only mode)
if exist('ReadMode','var')
    return
end

% panel position
f.UserData.y0 = f.UserData.y0 - opts.btn_pan_h - opts.spacer;
% panel
p = uipanel(f,'Tag','Buttons Panel',...
    'Position',[opts.spacer,f.UserData.y0,opts.left_pan_w,opts.btn_pan_h]);

% add buttons
btn_ypos = opts.btn_pan_h - (opts.spacer + opts.btn_h_l)*(1:num_btns);
for i = 1:num_btns
    uibutton(p,'Position',[opts.spacer,btn_ypos(i),opts.btn_w_l,opts.btn_h_l],...
        'Text',Text(i),'Icon',Icon(i),'ButtonPushedFcn',CallBack{i},...
        'Tooltip',"ctrl+"+Shortcut(i));
end

% add keyboard shortcuts to window 
f.KeyPressFcn = @(~,event) keyboard_shortcuts(event,Shortcut,CallBack);
end

function add_options_panel(f,opts)
%% Draw options panel for displaying tasks (different than settings options)

% create panel 
f.UserData.y0 = f.UserData.y0 - opts.opts_pan_h - opts.spacer;
p = uipanel(f,'Tag','Options Panel',...
    'Position',[opts.spacer,f.UserData.y0,opts.left_pan_w,opts.opts_pan_h]);

% add dropdown with label
ypos = opts.opts_pan_h - opts.spacer - opts.btn_h;
uilabel(p,'Text','Sort By:','FontSize',opts.fs,...
    'Position',[opts.spacer,ypos,opts.dr_lbl_w,opts.btn_h]);
xpos = 2*opts.spacer + opts.dr_lbl_w;
uidropdown(p,'Items',{'Due Date','Date Created','Date Completed','Custom'},...
    'Position',[xpos,ypos,opts.dr_w,opts.btn_h],'FontSize',opts.fs,...
    'Value',f.UserData.RankBy,...
    'ValueChangedFcn',@(dr,~)toggle_sort_option(f,dr));

% add label & checkboxes
ypos = ypos - opts.spacer - opts.btn_h;
uilabel(p,'Text','Show Tasks:','FontSize',opts.fs,...
    'Position',[opts.spacer,ypos,opts.chkbx_w,opts.btn_h]);

Text = ["Completed","Past Due","Deleted"];
Value_field = replace(Text,' ','');
for i = 1:3
    ypos = ypos - opts.spacer - opts.btn_h;
    uicheckbox(p,'Text',Text(i),'Value',f.UserData.Show.(Value_field(i)),...
        'FontSize',opts.fs,...
        'Position',[opts.spacer,ypos,opts.chkbx_w,opts.btn_h],...
        'ValueChangedFcn',@(chbx,~)toggle_display_includes(f,chbx,Value_field(i)));
end

% add apply button
btn_ypos = ypos - opts.spacer - opts.btn_h;
uibutton(p,'Text','Apply','FontSize',opts.fs,...
    'Position',[xpos,btn_ypos,80,opts.btn_h],'Tag','Apply Button',...
    'Visible',false,...
    'ButtonPushedFcn',@(btn,~)Apply_panel_options(f,btn,opts));
end

function Apply_panel_options(f,btn,opts)
%% Apply sorting and include options from options panel
btn.Visible = false;
update_tasks_panel(f,opts,'normal')
autosave_tasks(f,opts)
end

function toggle_display_includes(f,chbx,Value_field)
%% Callback for display task inclusion checkboxes in options panel
f.UserData.Show.(Value_field) = chbx.Value;
enable_options_panel_apply(f)
end

function toggle_sort_option(f,dr)
%% Set task sorting scheme from uidropdown
f.UserData.RankBy = dr.Value;
enable_options_panel_apply(f)
end

function enable_options_panel_apply(f)
%% Enable paneloptions apply
apply_btn = findobj(f,'Tag','Apply Button');
apply_btn.Visible = true;
end

function add_tasks_panel(f,opts)
%% Create Panel to Display Tasks 

task_pan = uipanel(f,'Tag','Tasks Panel','Scrollable','on',...
    'BackgroundColor',opts.task_pan_clr,...
    'Position',[opts.left_pan_w + 2*opts.spacer,opts.spacer,opts.task_pan_w,opts.task_pan_h]); 

if f.UserData.NumTasks == 0
    % add label to prompt adding tasks
    uilabel(task_pan,'Text','Add Tasks Here','FontSize',18,...
        'FontColor',[0 0 1],'Tag','Empty Tasks Label',...
        'Position',[0,0,[opts.task_pan_w,opts.task_pan_h] - opts.spacer],...
        'HorizontalAlignment','center','VerticalAlignment','center');
else
    % redeclare drawn status
    f.UserData = clear_UserData_isDrawn(f.UserData,opts);
end

% redraw panel to display the tasks
update_tasks_panel(f,opts,'normal')
end

function update_tasks_panel(f,opts,call_option)
%% Check for and update tasks panel GUI properties

% for brevity (and efficiency)
DescFontWeight  = f.UserData.DescFontWeight;
RankBy          = f.UserData.RankBy;

% establish parent figure and panel based on call option
switch call_option
    case 'normal'
        % 'real' task, draw to tasks panel
        parent_fig   = f;
        parent_panel = findobj(f,'Tag','Tasks Panel');
    case 'example'
        % example task, draw to settings subfigure
        settings_fig_name = ['Task Manager ',f.UserData.Name,' Settings'];
        f2 = findall(groot,'Name',settings_fig_name);
        if numel(f2) ~= 1
            error('Settings subfigure not found correctly')
        end
        parent_fig = f2;

        % find settings display panel
        parent_panel = findobj(f2,'Tag','Display');
         if numel(parent_panel) ~= 1
            error('Settings display panel not found correctly')
        end
end

% initializing updating status
parent_fig.Pointer = 'watch'; drawnow;
parent_panel.Visible = false; % *** CHANGE for debug

switch call_option
    case 'normal'

        % determine which tasks to display
        Display_vec = isDisplayed(f.UserData);
        display_ind = find(Display_vec);

        % early exit for no displayable tasks
        lbl_obj = findobj(f,'Tag','Empty Tasks Label');
        % Show empty tasks label
        if numel(display_ind) == 0
            try
                lbl_obj.Visible = true;
            catch
                disp('no add tasks label for no tasks displayable')
            end
            
            % show zeros on stats panel
            update_stats_pan(f)

        elseif ~isempty(lbl_obj) && lbl_obj.Visible
            % stop showing empty tasks label, if displayable tasks present
            lbl_obj.Visible = false;
        end

        % Loop on all created tasks (ones that arent displayed may need to
        % be removed)
        update_ind = 1:f.UserData.NumTasks;

    case 'example'
        % only one task to display / consider
        Display_vec = true(opts.max_num_tasks,1);
        display_ind = opts.max_num_tasks;
        update_ind  = opts.max_num_tasks;
end

% Read Urgency
Tasks = rank_urgency(f,display_ind);

% Read task layout
Tasks = read_task_layout(f,Tasks,display_ind,opts);

% Determine task positions
Tasks = read_task_position(f.UserData.NumTasks,display_ind,Tasks,RankBy,opts);

% Add placeholder panel for space above the top task
if strcmpi(call_option,'normal')
    move_place_holder_panel(parent_panel,Tasks(display_ind),opts)
end

% store read and ranked data
f.UserData.Tasks = Tasks;

% find tasks to be drawn in update
total_task_drawings = numel(find(~[Tasks(update_ind).isDrawn] & Display_vec(update_ind)));

% create progress bar if a certain amount
if total_task_drawings > opts.pgb_min
    pgb = uiprogressdlg(f,"Message","Loading Tasks...","ShowPercentage",true,'Value',0);
    pgb_exist = true;
    num_tasks_drawn = 0;
else
    pgb_exist = false;
end

% Loop through tasks and check + update all dynamic proprerties
for task_ind = update_ind

    Task = Tasks(task_ind);

    %% Collapsable

    if Task.isFolder && ~isempty(Task.SubTasks)
        collapsable = true;
    else
        collapsable = false;
    end

    %% Task Existence

    % Create task uipanel, with icons & labels. if needed.
    if ~Task.isDrawn && Display_vec(task_ind)
        create_task_panel(f,task_ind,parent_panel,opts);
        Task = f.UserData.Tasks(task_ind);

        % Create priority mover buttons ("to" and "from")
        if strcmpi(call_option,'normal')
            add_move_from_button(f,task_ind,parent_panel,opts);
            add_move_to_button(f,task_ind,parent_panel,opts);
        end

        % Find and store label objects for update_task_panel
        Task = store_task_objects(parent_panel,Task,task_ind,opts);
        f.UserData.Tasks(task_ind) = Task;

        % reflect as completed in uiprogressbar
        if pgb_exist
            num_tasks_drawn = num_tasks_drawn + 1;
            pgb.Value = num_tasks_drawn/total_task_drawings;
        end
    end

    % grab objects (brevity)
    if Task.isDrawn
        task_panel      = Task.Labels.Panel;
        move_from_btn   = Task.Labels.MoveFrom;
        move_to_btn     = Task.Labels.MoveTo;
        collapse        = Task.Labels.Collapse;
        desc            = Task.Labels.Description;
        date_str        = Task.Labels.DueDate;
    end

    %% Visibility

    % check that (should be) displayed matches visible
    if Task.isDrawn && task_panel.Visible ~= Display_vec(task_ind)
        task_panel.Visible = Display_vec(task_ind);
        if collapsable
            collapse.Visible = Display_vec(task_ind);
        end
    end

    if ~Display_vec(task_ind)
        if Task.isDrawn
            % make sure move to and move from buttons are not showing
            if move_from_btn.Visible
                move_from_btn.Visible = false;
            end
            if move_to_btn.Visible
                move_to_btn.Visible = false;
            end
        end
        % Nothing else to do for undisplayed tasks, move on
        continue
    end

    % exit early if nothing else to display
    if numel(display_ind) == 0
        parent_panel.Visible = true;
        f.Pointer = 'arrow';drawnow
        focus(f)
        return
    end

    %% Collapse existence

    if collapsable && isempty(collapse)
        % add collapsable icon if not already added and is appropriate
        collapse = add_collapse_icon(f,parent_panel,Task,task_ind,opts);

        % Store this object in userdata
        Task.Labels.Collapse = collapse;
        f.UserData.Tasks(task_ind) = Task;
    elseif ~collapsable && ~isempty(collapse)
        % remove collapse icon if already added and no longer appropriate
        delete(collapse)
    end

    %% Task Position

    stored_pos = [Task.xpos,Task.ypos];

    % update priority mover button locations
    if strcmpi(call_option,'normal') && task_panel.Position(2) ~= stored_pos(2)
        % y position
        move_from_btn.Position(2) = Task.PriorityBtnYPos;
        move_to_btn.Position(2)   = Task.PriorityBtnYPos;
    end

    % update task position and collapse icon
    if strcmpi(call_option,'normal') && ~isequal(task_panel.Position(1:2),stored_pos)
        % position (origin)
        task_panel.Position(1:2) = stored_pos;

        % adjust collapsable position
        if collapsable
            collapse.Position(1:2) = collapse_position(stored_pos,Task.Height,opts);
        end
    end

    % task width adjustment -- slow and annoying, but necessary-ish
    if task_panel.Position(3) ~= Task.Width
        % Adjust task button positions on new width, unless task panel
        % newly drawn (width of 0.5 used ot identiy that (stupid? not
        % sure)
        if task_panel.Position(3) ~= 0.5
            delta = Task.Width - task_panel.Position(3);
            % adjust icon buttons (all?)
            for btn_ind = 1:numel(Task.Labels.TaskBtns)
                btn = Task.Labels.TaskBtns(btn_ind);
                btn.Position(1) = btn.Position(1) + delta;
            end
        end
        task_panel.Position(3) = Task.Width;
    end

    %% Task Color

    if ~isequal(task_panel.BackgroundColor,Task.Color)
        task_panel.BackgroundColor = Task.Color;
    end

    %% Task Description

    % Description text
    if ~strcmp(desc.Text,Task.Name)
        desc.Text = Task.Name;
    end

    % Description fontweight
    if ~strcmpi(desc.FontWeight,DescFontWeight)
        desc.FontWeight = DescFontWeight;
    end

    %% Task Due Date String 

    if ~strcmpi(date_str.Text,DueDate_lbl_str(Task,opts))
        date_str.Text = DueDate_lbl_str(Task,opts);
    end

    %% Task Layout

    % Task height
    if task_panel.Position(4) ~= Task.Height
        task_panel.Position(4) = Task.Height;
    end

    % description height on panel
    desc_ypos = Task.Height - opts.spacer - opts.lbl_h;
    if desc.Position(2) ~= desc_ypos
        desc.Position(2) = desc_ypos;
    end

    % optional labels
    for vars = opts.OptionalFields

        field_str = replace(vars{1},' ','');

        % grab label objects, check if empty
        lbl_obj = Task.Labels.(field_str);
        if isempty(lbl_obj)
            error('Label object not found')
        end

        % cycle thorugh label objects associated with this string field
        % (Regularity has mult. objects)
        for lbl_ind = 1:numel(lbl_obj)
            lbl = lbl_obj(lbl_ind);
            % label visibility
            if lbl.Visible ~= Task.Show.(field_str)
                lbl.Visible = Task.Show.(field_str);
            end

            % Label height
            if lbl.Position(2) ~= Task.([field_str,'Height'])
                lbl.Position(2) = Task.([field_str,'Height']);
            end
        end
    end

    %% Priority mover buttons - visible / enable

    if strcmpi(call_option,'normal')
        % "move from" button: On for custom rank by mode
        if move_from_btn.Visible ~= strcmpi(RankBy,'Custom')
            move_from_btn.Visible = strcmpi(RankBy,'Custom');
        end
        
        % set enable on the off chance that update called while button
        % enabled.
        if ~move_from_btn.Enable && strcmpi(RankBy,'Custom')
            move_from_btn.Enable = true;
        end

        % "move to" button: automatically removed when tasks panel updated
        if move_to_btn.Visible
            move_to_btn.Visible = false;
        end
    end
end

% update state panel 
if strcmpi(call_option,'normal')
    update_stats_pan(f)
end

% finish updating
parent_panel.Visible  = 'on';
parent_fig.Pointer = 'arrow'; drawnow;

% remove progress bar
if pgb_exist
    delete(pgb)
end
focus(parent_fig) % yes! Rare victory here. This works (so far)
end

function Tasks = read_task_position(NumTasks,display_ind,Tasks,RankBy,opts)
%% Order task display and store task positions

% return original task indeces in sorted order
Original_Task_inds = display_ind([Tasks(display_ind).isOriginal]);
Original_Task_inds = order_tasks(Tasks,Original_Task_inds,RankBy);

% find net height for pannel object placement
net_task_height = sum([Tasks(display_ind).Height]) + (numel(display_ind) + 1) * opts.spacer;

% set beginning y-position
if net_task_height < opts.task_pan_h
    ypos = opts.task_pan_h - opts.spacer;
else
    ypos = net_task_height; % ~~~ need to add ypos spacer here! Not 100% sure how
end

start_xpos = opts.spacer;

% leave room for folder collapse icon only if used
if any([Tasks(display_ind).isFolder] & ~isempty([Tasks(display_ind).SubTasks]))
    start_xpos = start_xpos + opts.collapse_sz + opts.spacer;
end

% init pos vectors
Vectors.xpos            = cell(NumTasks,1);
Vectors.ypos            = cell(NumTasks,1);
Vectors.PriorityBtnYPos = cell(NumTasks,1);
Vectors.Width           = cell(NumTasks,1);

% set each original task and their subtasks position
for task_ind = Original_Task_inds
    [ypos,Vectors] = set_task_positions(Tasks,task_ind,RankBy,opts,start_xpos,ypos,Vectors,display_ind);
end

if task_ind == opts.max_num_tasks
    Tasks(opts.max_num_tasks).xpos  = Vectors.xpos{opts.max_num_tasks};
    Tasks(opts.max_num_tasks).ypos  = Vectors.ypos{opts.max_num_tasks};
    Tasks(opts.max_num_tasks).Width = Vectors.Width{opts.max_num_tasks};
else
    [Tasks(1:NumTasks).xpos]               = deal(Vectors.xpos{:});
    [Tasks(1:NumTasks).ypos]               = deal(Vectors.ypos{:});
    [Tasks(1:NumTasks).PriorityBtnYPos]    = deal(Vectors.PriorityBtnYPos{:});
    [Tasks(1:NumTasks).Width]              = deal(Vectors.Width{:});
end
end

function tf = isDisplayed(UserData,task_ind)
%% Read user options & return logical for displayable task indeces

% Either operate on all tasks or just one inputed
if exist('task_ind','var')
    Tasks = UserData.Tasks(task_ind);
else
    Tasks = UserData.Tasks(1:UserData.NumTasks);    
end

tf = true(1,numel(Tasks));

if ~UserData.Show.Deleted
    tf = tf & ~[Tasks.Deleted];
end

if ~UserData.Show.Completed
    tf = tf & ~[Tasks.Completed];
end

if ~UserData.Show.PastDue
    tf = tf & ~[Tasks.PastDue];
end

tf = tf & ~[Tasks.Collapsed];
end

function Task_inds = order_tasks(Tasks,Task_inds,RankBy)
%% Set the priority ranking and color for each task

% gui option values --> var names switch-case
switch RankBy
    case 'Due Date'
        sort_var = 'DueDateRank';
    case 'Date Created'
        sort_var = 'CreationDate';
    case 'Date Completed'
        sort_var = 'CompletionDate';
    case 'Custom'
        sort_var = 'Priority';
    otherwise
        error('elseif err')
end
% sort and return index vector to draw tasks in order of
[~,sorted_ind] = sort([Tasks(Task_inds).(sort_var)]);
Task_inds = Task_inds(sorted_ind);
end

function Tasks = rank_urgency(f,task_inds)
%% Set Color / status for for a given task

% ~~~ the "UrgencyLevel" calculation needs to be re-written here. Very
% weird and confusing now

% ~~~ this level of brevity is kinda unnecassary. Can remove now

UserData        = f.UserData;
Limits          = UserData.Limits; % brevity
Tasks           = UserData.Tasks;   % brevity
complete_clr    = UserData.complete_clr;
deleted_clr     = UserData.deleted_clr;
incomplete_clr  = UserData.incomplete_clr;
folder_clr      = UserData.folder_clr;
num_Limits      = numel(UserData.DurationLimits);

num_tasks   = numel(task_inds);
PastDue     = repmat({false},num_tasks,1);
DueDateRank = PastDue;
Color       = PastDue;
for i = 1:num_tasks

    task_ind = task_inds(i);
    if Tasks(task_ind).Deleted
        % (Deleted, displayed)
        UrgencyLevel    = num_Limits + 2;
        panel_clr       = deleted_clr;
        use_duedate     = false;
    elseif strcmpi(Tasks(task_ind).Type,'Ongoing')
        % (Ongoing)
        % Calculate Due Date from regularity and Completion OR Creation Date
        if Tasks(task_ind).Completed
            start_date = datetime(Tasks(task_ind).CompletionDate);
        else
            start_date = datetime(Tasks(task_ind).CreationDate);
        end
        f.UserData.Tasks(task_ind).DueDate = start_date + read_duration(Tasks(task_ind)); % ~~~ this is old and slow, but not used much. Will hold on fixing for now
        use_duedate = true;
    elseif Tasks(task_ind).Completed
        % (One time, complete)
        UrgencyLevel    = num_Limits + 3;
        panel_clr       = complete_clr;
        use_duedate     = false;
    elseif Tasks(task_ind).isFolder
        UrgencyLevel    = num_Limits + 2;
        panel_clr       = folder_clr;
        use_duedate     = false;
    elseif strcmpi(Tasks(task_ind).DueDate,'N/A')
        % (One time no due date, incomplete)
        UrgencyLevel    = num_Limits + 2;
        panel_clr       = incomplete_clr;
        use_duedate     = false;
    else
        % (One time w/ due date, incomplete)
        use_duedate = true;
    end

    if use_duedate
        % find urgency:
        time_left =  Tasks(task_ind).DueDate - datetime;

        if time_left < 0
            % Past Due Date
            PastDue{i} = true;
            UrgencyLevel = 0;
            panel_clr = f.UserData.pastdue_clr;
        else
            range_ind = find(time_left < f.UserData.DurationLimits,1);
            if isempty(range_ind)
                % "default clr" -- due date is further than the the last set limit
                UrgencyLevel    = num_Limits + 1;
                panel_clr       = f.UserData.default_clr;
            else
                % Within one of the time limits
                UrgencyLevel    = range_ind;
                panel_clr       = Limits(range_ind).Color;
            end
        end
    end

    % Assign
    DueDateRank{i} = UrgencyLevel + 1; % +1 accounts for past due
    Color{i}       = panel_clr;
end

[Tasks(task_inds).PastDue]       = deal(PastDue{:});
[Tasks(task_inds).DueDateRank]   = deal(DueDateRank{:});
[Tasks(task_inds).Color]         = deal(Color{:});
end

function Duration = read_duration(Struct)
%% Read duration from string inputs

% function_handle to get durtion ui inputs
Duration = eval([lower(Struct.DurationStr),'(',Struct.DurationVal,');']);
end

function Duration = weeks(num_weeks)
%% Function to use weeks as duration method
Duration = 7*days(num_weeks);
end

function Duration = months(num_weeks)
%% Function to use weeks as duration method
% ~~~ lol this is just a weak approximation for now. 
Duration = 31*days(num_weeks);
end

function p = create_task_panel(f,task_ind,parent,opts)
%% Create task panel, set constant properties

p = uipanel(parent,'Tag',['Task ',num2str(task_ind)]);
p.Position(3) = 0.5; % ~~~ hmmm, is this a good idea? it works, but is it good practice? Using value to identify the task panel as being recently created, for adjusting button icon widths

% add labels to panel
add_task_labels(f,p,task_ind,opts)

% add icons to panel
add_task_btns(f,p,task_ind,opts)
end

function [end_ypos,Vectors] = set_task_positions(Tasks,task_ind,RankBy,opts,xpos,ypos,Vectors,display_vec)
%% Establish task and sub task positions

Task = Tasks(task_ind);

% Move ypos
end_ypos = ypos - opts.spacer - Task.Height;

Vectors.xpos{task_ind} = xpos;
Vectors.ypos{task_ind} = end_ypos;
Vectors.PriorityBtnYPos{task_ind} = end_ypos + (Task.Height - opts.priority_btn_w)/2;
Vectors.Width{task_ind} = opts.mover_xpos - opts.spacer - xpos;

% Recursive call to subtasks
subtasks_plot = Task.SubTasks(ismember(Task.SubTasks,display_vec));
if ~isempty(subtasks_plot)
    xpos        = xpos + opts.tab_w;
    SubTasks    = order_tasks(Tasks,subtasks_plot,RankBy);    

    for ind = SubTasks
        [end_ypos,Vectors] = set_task_positions(Tasks,ind,RankBy,opts,xpos,end_ypos,Vectors,display_vec);
    end
end
end

function add_task_labels(f,p,task_ind,opts)
%% Add Labels to Task Panel

% ~~~ replace find by tag method with storing label objects to tasks struct
% array (smart, I hope)


% option to have background color for text labels
if opts.show_lbl_clr
    lbl_clr = {'BackgroundColor',opts.lbl_clr};
else
    lbl_clr = {};
end

Task = f.UserData.Tasks(task_ind);

if isempty(Task.Width)
    error('why is this occuring? Please Fix') % ~~~
end

% Write description
lbl_pos = [opts.spacer,0,Task.Width - 2*opts.spacer,opts.lbl_h];
uilabel(p,'Position',lbl_pos,'Text',Task.Name,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['description ',num2str(task_ind)]);

% Write Creation date

if isdatetime(Task.CreationDate)
    display_date = char(Task.CreationDate,opts.DateFormat);
else
    display_date = Task.CreationDate;
end
lbl_str      = ['Created ',display_date];
uilabel(p,"Text",lbl_str,'Position',lbl_pos,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Creation Date ',num2str(task_ind)]);

% Write type
uilabel(p,'Position',lbl_pos,'Text',Task.Type,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Type ',num2str(task_ind)]);

% Write completion date
lbl_str = completed_task_string(Task,opts);

if strcmp(Task.Type,'Ongoing')
    lbl_str = ['Last ',lbl_str];
end
uilabel(p,'Position',lbl_pos,'Text',lbl_str,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Completion Date ',num2str(task_ind)]);

% Write Regularity

lbl_str = Task.DurationVal;
lbl_pos(2) = Task.RegularityHeight;
uilabel(p,'Position',lbl_pos,'Text',lbl_str,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Regularity ',num2str(task_ind)]);

lbl_str = Task.DurationStr;
lbl_pos(1) = lbl_pos(1) + 50;
uilabel(p,'Position',lbl_pos,'Text',lbl_str,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Regularity ',num2str(task_ind)]);
lbl_pos(1) = lbl_pos(1) - 50;

% Write Due Date
lbl_str = DueDate_lbl_str(Task,opts);
lbl_pos(2) = Task.DueDateHeight;
uilabel(p,'Position',lbl_pos,'Text',lbl_str,lbl_clr{:},'FontSize',opts.fs,...
    'Tag',['Due Date ',num2str(task_ind)]);
end

function string = completed_task_string(Task,opts)
%% Returns string for label object with task completion date 
if Task.Completed
    string = ['Completed ',char(Task.CompletionDate,opts.DateFormat)];
else
    string = 'Incomplete';
end
end

function add_task_btns(f,p,Task_ind,opts)
%% Add Icon buttons to Task Panel

isFolder = f.UserData.Tasks(Task_ind).isFolder;
if isFolder
    edit_str = 'edit folder';
else
    edit_str = 'edit task';
end

% Define all of the task icon buttons

% Comment
Comment.Tooltip     = 'Add Comment';
Comment.CallBack    = @(~,~)edit_comment(f,Task_ind,opts);
Comment.Visible      = true;
if isempty(f.UserData.Tasks(Task_ind).Comment)
    Comment.Icon    = 'notes.jpg';
else
    Comment.Icon    = 'notes_present.png';
end

% Subtask
Subtask.Tooltip     = 'Add Subtask';
Subtask.Icon        = 'plus.png';
Subtask.CallBack    = @(~,~)add_task_gui(f,Task_ind,opts,'new task'); 
Subtask.Visible      = true;

% Subfolder
Subfolder.Tooltip   = 'Add Subfolder';
Subfolder.Icon      = 'folder.jpg';
Subfolder.CallBack  = @(~,~)add_task_gui(f,Task_ind,opts,'new folder'); 
Subfolder.Visible    = true;

% Edit
Edit.Tooltip        = 'Edit Item';
Edit.Icon           = 'edit.jpg';
Edit.CallBack       = @(~,~)add_task_gui(f,Task_ind,opts,edit_str);
Edit.Visible         = true;

% Complete
if f.UserData.Tasks(Task_ind).Completed
    Complete.Icon   = 'uncomplete.png';
    Complete.Tooltip = 'Set Task to Incomplete';
else
    Complete.Icon    = 'checkmark.png';
    Complete.Tooltip = 'Complete Task';
end
Complete.CallBack   = @(~,~)toggle_complete_task_wrapper(f,Task_ind,opts);
Complete.Visible    = ~isFolder;

% Delete
Delete.Tooltip      = 'Delete Task';
Delete.Icon         = 'trash.png';
Delete.CallBack     = @(~,~)toggle_delete_task_wrapper(f,Task_ind,opts);
Delete.Visible       = true; % ~~~ this should change. Or something should. brainstorm. l8r.

Buttons = [Complete,Subtask,Subfolder,Comment,Edit,Delete];

% positioning
num_btns    = numel(Buttons);
icons_width = num_btns*(opts.icon_sz + opts.spacer);
icon_xpos0  = f.UserData.Tasks(Task_ind).Width - icons_width;
icon_pos    = [icon_xpos0,opts.spacer,opts.icon_sz,opts.icon_sz];

% initialize graphics place holder array to store buttons to Task Data
TaskBtns = gobjects(num_btns,1);
btn_ind = 0;

for Button = Buttons
    b = uibutton(p,'Position',icon_pos,'Text','',...
    'Icon',Button.Icon,...
    'Tooltip',Button.Tooltip,...
    'Tag',[Button.Tooltip,' ',num2str(Task_ind)],...
    'Visible',Button.Visible);

    % For displaying example, dont associate any functionality
    if Task_ind ~= opts.max_num_tasks
        b.ButtonPushedFcn = Button.CallBack;
    end

    % store in task
    btn_ind = btn_ind + 1;
    TaskBtns(btn_ind) = b;

    % Move xpos to the right
    icon_pos(1) = icon_pos(1) + opts.spacer + opts.icon_sz;
end
f.UserData.Tasks(Task_ind).Labels.TaskBtns = TaskBtns;
end

function move_from_btn = add_move_from_button(f,task_ind,parent_panel,opts)
%% Create priority mover button for given task

move_from_btn = uibutton(parent_panel,'Tag',['Move from ',num2str(task_ind)],...
        'Icon','PriorityMover.png',...
        'Position',[opts.mover_xpos,0,opts.priority_btn_w * [1,1]],...
        'ButtonPushedFcn',@(btn,~)prompt_priority_move(f,parent_panel,task_ind,btn),...
        'Text','','Visible',false);
end

function move_to_btn = add_move_to_button(f,task_ind,parent_panel,opts)
%% Create priority move to button for given task

move_to_btn = uibutton(parent_panel,'Icon','PriorityMoverLocation.png',...
    'Position',[opts.mover_xpos,0,opts.priority_btn_w * [1,1]],...
    'Tag',['Move to ',num2str(task_ind)],'Text','',...
    'ButtonPushedFcn',@(~,~)move_priority(f,task_ind,opts,'manual'));
end

function prompt_priority_move(f,parent_panel,task_ind,btn)
%% Show options to change task priority ; priority mover button callback

% Group object tags...SUPER annoying I cant do {p.Children.Tag}
num_children = numel(parent_panel.Children);
Tags = cell(num_children,1);
for i = 1:num_children
    Tags{i} = parent_panel.Children(i).Tag;
end

% Remove all other priority buttons (invisible)
other_mover_btns = contains(Tags,'Move from') & ~strcmp(Tags,btn.Tag);
other_mover_btns = parent_panel.Children(other_mover_btns);
[other_mover_btns.Visible] = deal(false);

% find sibling tasks for potential priority moves
siblings = find_siblings(f,task_ind);
if isempty(siblings)
    % ~~~ (l8r) should display something that there's no where to move!
    return
end

% store user data for move_to selection
f.UserData.move_from_ind    = task_ind;
f.UserData.moving_siblings  = siblings;

% disable this button (so we cant keep calling this function)
btn.Enable = false;

% Set move to buttons visible for all sibling tasks
for sibling = siblings(isDisplayed(f.UserData,siblings))
    move_to_btn = findobj(parent_panel,'Tag',['Move to ',num2str(sibling)]);
    move_to_btn.Visible = true;
end

% Add escape key callback to go back to moving task selector
f.WindowKeyPressFcn = @(f,key)Escape_move_mode(f,key,other_mover_btns,btn);
focus(f)
end

function Escape_move_mode(f,key,other_mover_btns,btn)
%% Escape key from priority moving mode

if double(key.Character) ~= 27 % 'escape' key
    return
end

task_pan        = findobj(f,'Tag','Tasks Panel');
task_pan_btns   = findobj(task_pan,'Type','uiButton');

% remove moving location buttons
move_to_btns_ind = contains({task_pan_btns.Tag},'Move to');
[task_pan_btns(move_to_btns_ind).Visible] = deal(false);

% redraw mover buttons
[other_mover_btns.Visible] = deal(true);

% reenable original moving button
btn.Enable = true;
end

function siblings = find_siblings(f,Task_ind)
%% Find Sibling Tasks to given task_ind
% used for moving priority
if f.UserData.NumTasks == 0
    siblings = [];
    return
end

ParentTask = f.UserData.Tasks(Task_ind).ParentTask;
if isempty(ParentTask)
    siblings = find([f.UserData.Tasks(1:f.UserData.NumTasks).isOriginal]);
else
    siblings = f.UserData.Tasks(ParentTask).SubTasks;
end
siblings = siblings(siblings ~= Task_ind);
end

function move_priority(f,move_to_ind,opts,call_option)
%% Change the priority of task amongst siblings ; callback for loaction btn

% store old userdata for undo 
f.UserData.Old = f.UserData;

% grab moving ind from user data
move_from_ind = f.UserData.move_from_ind;

% reset escape key
f.WindowKeyPressFcn = @(f,keypress)'';

% set priority value for task being moved :
move_priority   = f.UserData.Tasks(move_from_ind).Priority;
end_priority    = f.UserData.Tasks(move_to_ind).Priority;
f.UserData.Tasks(move_from_ind).Priority = end_priority;

% set priority value for tasks in between move_from and move_to :

% establish move direction
dir = (end_priority - move_priority)/abs(end_priority - move_priority);

% grab current moving siblings
siblings = f.UserData.moving_siblings;

% all tasks move +1 or -1 depending on direction of movement
move_priorities = move_priority + dir :dir : end_priority;
for priority = move_priorities

    % identify sibling task (per loop)
    sibling_ind      = [f.UserData.Tasks(siblings).Priority] == priority;
    sibling_task_ind = siblings(sibling_ind);

    % move task priority (opposite of original task moving direction)
    f.UserData.Tasks(sibling_task_ind).Priority = priority - dir;
end

if strcmpi(call_option,'manual') % automatic calls will update on their own
    % draw the tasks again
    update_tasks_panel(f,opts,'normal');
    
    % Auto-save
    autosave_tasks(f,opts)
end
end

function edit_comment(f,Task_ind,opts)
%% Display and allow Edit of task comment
% Idea: Icon button opens/closes notes uitextarea. And by that I mean uses
% 'Visible' property. Not literally opening or closing seperate window

% options :
area = [450,100];
background_color = [.97,.97,.72]; % sort of a notepad yellow, if you will
FontSize = opts.fs; % borrow same fontsize as everything else, for now

% look for existing text area
Tag         = ['Comment ',num2str(Task_ind)];
tasks_panel = findobj(f,'Tag','Tasks Panel');
tx_obj      = findobj(tasks_panel,'Tag',Tag);
btn         = findobj(tasks_panel,'Tag',['Add Comment ',num2str(Task_ind)]);
Task        = f.UserData.Tasks(Task_ind);
% complicated position statement here but it works
tx_origin = [Task.xpos,Task.ypos]...
    + [btn.Position(1),sum(btn.Position([2,4]))] - [area(1),0];

if isempty(tx_obj)
    % create the textarea! Where the meat is here, if you will

    if isempty(Task.Comment)
        str_val = 'Add comment here';
    else
        str_val = Task.Comment;
    end

    uitextarea(tasks_panel,'Position',[tx_origin,area],'Tag',Tag,...
        'Value',str_val,'ValueChangedFcn',@(tx,~)store_comment(f,Task_ind,tx),...
        'ValueChangingFcn',@(tx,event)quick_comment_close(f,Task_ind,opts,event),...
        'BackgroundColor',background_color,...
        'FontSize',FontSize);
else
    % check for multiple lines in comment ~~~ this is an existing bug that
    % still happens occasionally but shouldnt be here. I guess this works
    if numel(tx_obj.Value) > 1
        tx_obj.Value = tx_obj.Value{1};
    end

    % re-calculate position
    tx_obj.Position(1:2) = tx_origin;

    % Toggle visibility
    tx_obj.Visible = ~tx_obj.Visible;
    if isempty(tx_obj.Value{1})
        tx_obj.Value = 'Add comment here';
    end

    % reset Icon as neccssary 
    comment_present = ~strcmpi(tx_obj.Value,'Add comment here');
    if comment_present && strcmp(btn.Icon,'notes.jpg')
        btn.Icon = 'notes_present.png';
    elseif ~comment_present && strcmp(btn.Icon,'notes_present.png')
        btn.Icon = 'notes.jpg';
    end
end
autosave_tasks(f,opts)
focus(f)
end

function store_comment(f,Task_ind,tx)
%% Store comment to userdata as value is changed (callback)
f.UserData.Tasks(Task_ind).Comment = tx.Value{1};
end

function add_task_gui(f,task_ind,opts,option)
%% GUI for adding new task to figure or existing task group

% note on inputs :
% option is either 'new' or 'edit'
% if 'new', then task_ind refers to the parent task ([] if new original)
% if 'edit', then task_ind refers to the exisiting task

% subfigure width 
subfigure_w = 4*opts.spacer + opts.lbl_w + opts.desc_w + opts.btn_w_s;

% create subfigure
f2 = uifigure('Name',option,'Resize','off','Tag',['Task Manager ',f.UserData.Name,' Add/Edit Task']); 
f2.UserData.isExpanded = false;

% "add more" and "convert to" buttons for new and edit respectively
last_btn_pos = [opts.spacer,opts.spacer,opts.lbl_w,opts.tx_h];

if contains(option,'new')
    % Add more tasks
    % uibutton(f2,'Text','Add More...','FontColor',[0,0,1],'Position',more_pos,...
    %     'ButtonPushedFcn',@(~,self)add_more_tasks(f2,self,opts))
    uicontrol(f2,'Style','text','String','Add More',...
        'ForegroundColor',[0,0,1],'Position',last_btn_pos,...
        'ButtonDownFcn',@(~,self)add_more_tasks(f,f2,self,task_ind,option,opts),...
        'Enable','inactive',...
        'HorizontalAlignment','left','FontSize',10);
    % advance start ypos from "last button"
    start_ypos = 2*opts.spacer + opts.tx_h;
elseif contains(option,'edit')
    % Convert button

    if contains(option,'task')
        convert_text = 'Folder';
    elseif contains(option,'edit')
        convert_text = 'Task';
    else
        error('elseif err')
    end

    % larger height for btn vs txt
    last_btn_pos(4) = opts.btn_h;

    % convert button position
    uibutton(f2,'Text',['Convert to ',convert_text],'Position',last_btn_pos,...
        'ButtonPushedFcn',@(btn,~)convert_task_item(f,f2,task_ind,opts));

    % advance start ypos from "last button"
    start_ypos = 2*opts.spacer + opts.btn_h;
else
    error('elseif err') % ~~~ this is actually stupid (keep the other two)
end


% Draw GUI Prompts for adding tasks
num_tasks = 1;
end_ypos = draw_add_task_prompts(f,f2,task_ind,start_ypos,num_tasks,opts,option);

f2.Position(3:4) = [subfigure_w,end_ypos]; centerfig(f2);
end

function add_task(f,f2,parent_task_ind,opts,isFolder)
%% Add new task to figure or existing task group

% Save old data
f.UserData = store_previous_tasks(f.UserData);

% Cycle thorugh the add task text areas which aren't empty (see "get_add_task_ind_from_f2")
for add_task_ind = get_add_task_ind_from_f2(f2,opts)'
    % New task reference index
    f.UserData.NumTasks = f.UserData.NumTasks + 1;
    task_ind            = f.UserData.NumTasks;
    Tasks               = f.UserData.Tasks;
    Task                = Tasks(task_ind);

    % assign task attributes:
    Task.CreationDate   = datetime;
    Task.Collapsing     = false;
    Task.Completed      = false;
    Task.Deleted        = false;
    Task.isDrawn        = false;
    Task.isFolder       = isFolder;
    % assign GUI-contingent task attributes
    Task = add_contingent_attributes(f2,Task,add_task_ind,opts,isFolder);

    % Set original flag and parent ind
    if isempty(parent_task_ind)
        Task.Collapsed  = false;
        Task.isOriginal = true;
        Task.ParentTask = [];
    else
        Task.isOriginal = false;
        Task.ParentTask = parent_task_ind;
        % add new task to the parent task subtask list
        Tasks(parent_task_ind).SubTasks = ...
            [Tasks(parent_task_ind).SubTasks,task_ind];
        f.UserData.Tasks(parent_task_ind) = Tasks(parent_task_ind);
        
        % set collapsed status based on parent
        Task.Collapsed = Tasks(parent_task_ind).Collapsing;
    end

    % Assign New Task to task list to assess siblings
    f.UserData.Tasks(task_ind) = Task;

    % Task Priority (amongst siblings) (default last)
    siblings = find_siblings(f,task_ind);
    f.UserData.Tasks(task_ind).Priority = numel(siblings) + 1;

    completed_siblings = siblings([Tasks(siblings).Completed]);
    if f.UserData.AutoSetPriority && ~isempty(completed_siblings)
        % set task above completed tasks

        % find new priority to switch this task to : the highest completed
        % task
        [~,switch_ind]              = min([Tasks(completed_siblings).Priority]);
        switching_task              = completed_siblings(switch_ind);
        f.UserData.move_from_ind    = task_ind;
        f.UserData.moving_siblings  = siblings;

        move_priority(f,switching_task,opts,'auto')
    end

    % Uncomplete parent task as necessary (if exists, if is folder, and if currently complete)
    if ~isempty(parent_task_ind) && Tasks(parent_task_ind).isFolder && Tasks(parent_task_ind).Completed
        f.UserData.Tasks(parent_task_ind).Completed = false;
    end
end

% wrap it up :
close(f2)
update_tasks_panel(f,opts,'normal')
autosave_tasks(f,opts)
end

function  Task = add_contingent_attributes(f2,Task,add_task_ind,opts,isFolder)
%% Add the attributes read from add_task_GUI to new or exisitng task

% ~~~ note/question: Assigning PastDue here might be redundant, shouldnt be
% assessed in rank_task_priority after task creation in update_tasks_panel?

add_task_ind = num2str(add_task_ind);

% Read GUI inputs

tx = findobj(f2,'Tag',['Task Name',add_task_ind]);
if isFolder
    % no type, durations, due dates
    Task.Type = 'One time event';
    Task.DurationStr    = 'N/A';
    Task.DurationVal    = 'N/A';
    Task.DueDate        = 'N/A';
else
    % read type, durations, duedates

    uisw    = findobj(f2,'Tag',['Task Type',add_task_ind]);
    date_tx = findobj(f2,'Tag',['Due Date Text',add_task_ind]);
    dur_val = findobj(f2,'Tag',['Duration Value',add_task_ind]);
    dur_str = findobj(f2,'Tag',['Duration String',add_task_ind]);

    % Set the contingent properties from GUI objects
    if strcmp(uisw.Value,'Ongoing')
        Task.DurationStr    = dur_str.Value;
        Task.DurationVal    = dur_val.Value{1};
        Task.DueDate        = 'N/A'; % For init -- will be reassigned when draw figure (or draw task in future) is called
        Task.PastDue        = false;
    else
        % Assign date time
        try     % ~~~ try catch is (in my opinion) kinda bad !! can we replace?
            date_str = date_tx.Value{1};
            if  strcmpi(date_str,'n/a')
                dt = upper(date_str);
                Task.PastDue = false;
            else
                dt = datetime(date_str,'InputFormat',opts.DateFormat); % Display this somewhere! ~~~ Or except other formats!
                Task.PastDue = dt < datetime();
            end
        catch
            % warning / not created
            warndlg('Error reading Due Date; Task not created')
            return
        end
        Task.DueDate        = dt;
        Task.DurationStr    = 'N/A';
        Task.DurationVal    = 'N/A';
    end

    % read type
    Task.Type = uisw.Value;
end

% Bad input catch ~~~ need much more here
if isempty(tx.Value{1})
    warndlg('Task Description Cannot be Empty')
    Task = 0;
    return
end

% read name 
Task.Name = tx.Value{1};
end

function add_more_tasks(f,f2,self,parent_task_ind,option,opts)
%% Expand add task GUI to add multiple tasks with one input window

f2.Pointer = 'watch'; drawnow
f2.UserData.isExpanded = true;

% folder vs task
if contains(option,'folder')
    call_option = 'new folder';
else
    call_option = 'new_task';
end

% remove everything from "add task" subfigure
clf(f2)

% add new tasks
num_tasks = opts.num_add_tasks;
% draw from bottom (no 'add more prompt' (for now)
start_ypos = opts.spacer;
end_ypos = draw_add_task_prompts(f,f2,parent_task_ind,start_ypos,num_tasks,opts,call_option);

% Expand and move figure
f2.Position(4) = end_ypos;

% remove add more option
delete(self)

centerfig(f2)

f2.Pointer = 'arrow'; drawnow
end

function end_ypos = draw_add_task_prompts(f,f2,task_ind,start_ypos,num_tasks,opts,option)
%% Draw GUI Elements to prompt and register new task(s) and Banner

% ~~~ inputs here are extremely messy, worth fixing even. 
% when option is 'edit', the input var 'task_ind' is the task selected to
% edit
% when option is 'new', 'task_ind' is the new task's parent task. 
% That's confusing to return to
% ^ this message has two appearences

% maybe use options here? not super important ~~~
banner_h        = 22;
banner_fs       = 16;

% add task prompts
ypos = start_ypos;

for add_task_ind = num_tasks:-1:1 % going backwards so that top is 1, bottom is num_tasks
    final_task = add_task_ind == num_tasks;
    ypos = add_task_prompt(f,f2,ypos,task_ind,add_task_ind,final_task,opts,option);
end

% Add banner
ypos        = ypos + opts.spacer;
banner_w    = opts.desc_w; % good enough

if contains(option,'folder')
    item_type = 'Folder';
else
    item_type = 'Task';
end

if contains(option,'new')
    if isempty(task_ind)
        banner_txt = ['Add New Original ',item_type];
    else
        banner_txt = ['Add New ',item_type,' to "',f.UserData.Tasks(task_ind).Name,'"'];
    end
elseif contains(option,'edit')
    banner_txt = ['Edit "',f.UserData.Tasks(task_ind).Name,'"'];
end
uilabel(f2,'Text',banner_txt,'FontSize',banner_fs,...
    'Position',[opts.spacer,ypos,banner_w,banner_h]);

end_ypos = ypos + banner_h;
end

function ypos = add_task_prompt(f,f2,ypos,task_ind,add_task_ind,final_task,opts,option)
%% Add GUI Elements to prompt new task

% ~~~ inputs here are extremely messy, worth fixing even. 
% when option is 'edit', the input var 'task_ind' is the task selected to
% edit
% when option is 'new', 'task_ind' is the new task's parent task. 
% That's confusing to return to
% ^ this message has two appearences

add_task_ind = num2str(add_task_ind);

if contains(option,'task')
    %% Once vs. Ongoing switch

    % ~~~ This is the thing where we want to move the switch position, have to
    % wait for outer position, look into later (maybe a function off?)
    sw = uiswitch(f2,'Position',[92,ypos,45,opts.tx_h],...
        'Items',["One time event","Ongoing"],'Tag',['Task Type',add_task_ind],...
        'ValueChangedFcn',@(uisw,~)set_ongoing(f2,uisw));
    if contains(option,'edit')
        sw.Value = f.UserData.Tasks(task_ind).Type;
    end
    % ~~~ Currently disabling task deadline type switch. Havem't worked with
    % re-occuring events yet
    sw.Enable = false;
    ypos = ypos + opts.spacer + opts.btn_h;

    %% Due Date uilabel & textarea

    duedate_pos = [opts.spacer,ypos,opts.lbl_w,opts.btn_h];
    uilabel(f2,'Text','Due Date: ','Tag','Due Date Label',...
        'Position',duedate_pos);
    duedate_pos_tx = duedate_pos;
    duedate_pos_tx([1,3]) = [2*opts.spacer + opts.lbl_w,opts.duedate_tx_w];
    if isempty(task_ind) || f.UserData.Tasks(task_ind).isFolder
        date_str = f.UserData.DefaultDueDate;
    else
        % Pass on parent task due date as default child task due date
        if isdatetime(f.UserData.Tasks(task_ind).DueDate)
            date_str = char(f.UserData.Tasks(task_ind).DueDate,opts.DateFormat);
        else
            date_str = f.UserData.Tasks(task_ind).DueDate;
        end
    end
    uitextarea(f2,'Position',duedate_pos_tx,'Value',date_str,...
        'Tag',['Due Date Text',add_task_ind]);
    ypos    = ypos + opts.spacer + opts.btn_h;
end

%% description
% add label

if contains(option,'task')
    desc = 'Task Description:';
elseif contains(option,'folder')
    desc = 'Folder Description:';
else
    error('elseif err')
end

lbl_pos = [opts.spacer,ypos,opts.lbl_w,opts.btn_h];
uilabel(f2,'Text',desc,'Position',lbl_pos);

% add description uitext area
tx_pos = [2*opts.spacer + opts.lbl_w,ypos,opts.desc_w,opts.btn_h];
tx = uitextarea(f2,'Position',tx_pos,'Tag',['Task Name',add_task_ind]);
if contains(option,'edit')
    tx.Value = f.UserData.Tasks(task_ind).Name;
end

%% Add/Save Button -- conditional to function option 'edit' or 'new'
if final_task
    xpos    = 3*opts.spacer + opts.lbl_w + opts.desc_w;
    b       = uibutton(f2,'Position',[xpos,ypos,opts.btn_w_s,opts.btn_h]);
    if contains(option,'new')
        b.Text = 'Add';
        isFolder = contains(option,'folder');
        b.ButtonPushedFcn = @(~,~)add_task(f,f2,task_ind,opts,isFolder);
    elseif contains(option,'edit')
        b.Text = 'Save';
        b.ButtonPushedFcn = @(~,~)save_task_edit(f,f2,task_ind,opts);
    else
        error('elseif err') % per Jeremy
    end
end

ypos = ypos + opts.spacer + opts.btn_h;
end

function set_ongoing(f2,uisw)
%% Toggle on-going or one time event due date object visability

ongoing_lbl     = findobj(f2,'Tag','Duration Label');
ongoing_dirval  = findobj(f2,'Tag','Duration Value');
ongoing_dirstr  = findobj(f2,'Tag','Duration String');

duedate_lbl     = findobj(f2,'Tag','Due Date Label');
duedate_tx      = findobj(f2,'Tag','Due Date Text');

Ongoing_tf = strcmp(uisw.Value,'Ongoing');

ongoing_lbl.Visible     = Ongoing_tf;
ongoing_dirval.Visible  = Ongoing_tf;
ongoing_dirstr.Visible  = Ongoing_tf;

duedate_lbl.Visible     = ~Ongoing_tf;
duedate_tx.Visible      = ~Ongoing_tf;
end

function toggle_complete_task_wrapper(f,Task_ind,opts)
%% Wrapper function for complete_task (so we only redraw figure once)
f.Pointer = 'watch';drawnow
f.UserData = store_previous_tasks(f.UserData);

% individual function call w/ recursive calls for subtasks
toggle_complete_task(f,Task_ind,opts)

% enable resort button
if ~any(strcmp(f.UserData.RankBy,{'Date Created','Custom'})) % ~~~ weird caveat but I guess thats accurate
    enable_options_panel_apply(f)
end

% bring completion flag deltas to display
update_tasks_panel(f,opts,'normal')

% save and finish
autosave_tasks(f,opts)
f.Pointer = 'arrow';
end

function toggle_complete_task(f,Task_ind,opts)
%% Toggle task completion and update parent task

% toggle completion state
complete_state = ~f.UserData.Tasks(Task_ind).Completed;
f.UserData.Tasks(Task_ind).Completed        = complete_state;

% completion date 
if complete_state
    f.UserData.Tasks(Task_ind).CompletionDate   = datetime;
else
    f.UserData.Tasks(Task_ind).CompletionDate   = 'N/A';
end

% update task completion label object text
lbl_obj = findobj(f,'Tag',['Completion Date ',num2str(Task_ind)]);
lbl_obj.Text = completed_task_string(f.UserData.Tasks(Task_ind),opts); 

% update icon 
if complete_state
    icon    = 'uncomplete.png';
    tooltip = 'Set Task to Incomplete';
else
    icon    = 'checkmark.png';
    tooltip = 'Complete Task';
end

f.UserData.Tasks(Task_ind).Labels.TaskBtns(1).Icon    = icon;
f.UserData.Tasks(Task_ind).Labels.TaskBtns(1).Tooltip = tooltip;

% Check to toggle completion for parent_task recursively if exists and is folder
if ~f.UserData.Tasks(Task_ind).isOriginal
    parent_ind = f.UserData.Tasks(Task_ind).ParentTask;
    if f.UserData.Tasks(parent_ind).isFolder && ...
            ((complete_state && isComplete_folder(f,parent_ind)) || ...
            (~complete_state && f.UserData.Tasks(parent_ind).Completed))
        toggle_complete_task(f,parent_ind,opts)
    end
end

% switch priority as needed :

% find lowest-priority incomplete task
Tasks = f.UserData.Tasks;
siblings = find_siblings(f,Task_ind);

incomplete_siblings = siblings(~[Tasks(siblings).Completed]);
if f.UserData.AutoSetPriority && ~isempty(incomplete_siblings) && complete_state
    % set task below incomplete tasks

    % find new priority to switch this task to : the lowest incomplete task
    [low_incomp_priority,switch_ind] = max([Tasks(incomplete_siblings).Priority]);

    % If this task is lower than the recenetly completed task, switch 'em
    if low_incomp_priority > f.UserData.Tasks(Task_ind).Priority
        f.UserData.move_from_ind    = Task_ind;
        f.UserData.moving_siblings  = siblings;
        switching_task              = incomplete_siblings(switch_ind);
        move_priority(f,switching_task,opts,'auto')
    end
end
end

function toggle_delete_task_wrapper(f,Task_ind,opts)
%% Wrapper function for delete_task (so we only redraw and save once)
f.Pointer = 'watch'; drawnow

% save old data for undo button
f.UserData = store_previous_tasks(f.UserData);

% original call with recursive calls
toggle_delete_task(f,Task_ind)

% Complete parent task if exists and folder that is not complete
if ~f.UserData.Tasks(Task_ind).isOriginal
    parent_ind = f.UserData.Tasks(Task_ind).ParentTask;
    if (isComplete_folder(f,parent_ind) && ~f.UserData.Tasks(parent_ind).Completed)...
            || (~isComplete_folder(f,parent_ind) && f.UserData.Tasks(parent_ind).Completed)
        toggle_complete_task(f,parent_ind,opts)
    end
end

% update display
update_tasks_panel(f,opts,'normal')

% save task data
autosave_tasks(f,opts)

f.Pointer = 'arrow'; drawnow
end

function toggle_delete_task(f,Task_ind)
%% Delete task and subtasks

% switch delete state of task item
delete_state = ~f.UserData.Tasks(Task_ind).Deleted;

f.UserData.Tasks(Task_ind).Deleted = delete_state;

% Reflect delete state in icon 
if delete_state
    delete_icon = 'undelete.jpg';
else
    delete_icon = 'trash.png';
end

if ~isempty(f.UserData.Tasks(Task_ind).Labels)
    f.UserData.Tasks(Task_ind).Labels.TaskBtns(end).Icon = delete_icon;
end

for ind = f.UserData.Tasks(Task_ind).SubTasks 
    toggle_delete_task(f,ind)
end
end

function save_task_edit(f,f2,Task_ind,opts)
%% Apply callback for edit task gui

f.Pointer = 'watch';
% Save old data
f.UserData = store_previous_tasks(f.UserData);

% New task contingent attributes :
isFolder = f.UserData.Tasks(Task_ind).isFolder;
f.UserData.Tasks(Task_ind) = add_contingent_attributes(f2,f.UserData.Tasks(Task_ind),1,opts,isFolder);
close(f2)

% update to display
update_tasks_panel(f,opts,'normal')

% save and finish
autosave_tasks(f,opts)
f.Pointer = 'arrow';
end

function autosave_tasks(f,opts,manual)  %#ok<INUSD>
%% save tasks to task manager file

manual_save = exist('manual','var');
% only autosave if flag enabled
if ~(f.UserData.Autosave || manual_save)
    % establish that there is data that hasnt been saved
    if ~f.UserData.UnsavedChangesPresent
        f.UserData.UnsavedChangesPresent = true;
    end
    return
end

% note that changes have been saved
if f.UserData.UnsavedChangesPresent
    f.UserData.UnsavedChangesPresent = false;
end

% filer uiobjects out of userdata (dont save 'em)
UserData = rmv_gui_objects(f.UserData);

% remove "Undo" user data (struct gets too big otherwise)
if isfield(UserData,'Old')
    UserData = rmfield(UserData,'Old');
end

% save userdata
save(fullfile(opts.manager_loc,f.UserData.Name),'UserData')

% change and highlight save time
tx_obj      = findobj(f,'Tag','Autosave Label');
tx_obj.Text = autosave_str;
QuickHighlight(tx_obj,f)
end

function restore_previous_tasks(f,opts)
%% undo previous add, delete or completion

if~ isfield(f.UserData,'Old')
    errordlg('No saved changes to revert.')
    return
end

f.Pointer = 'watch';drawnow

% delete any new tasks (wont happen within update tasks pannel function)
num_tasks = f.UserData.NumTasks;
if num_tasks > f.UserData.Old.NumTasks
    task_panel      = f.UserData.Tasks(num_tasks).Labels.Panel;
    move_from_btn   = f.UserData.Tasks(num_tasks).Labels.MoveFrom;
    move_to_btn     = f.UserData.Tasks(num_tasks).Labels.MoveTo;
    delete(task_panel)
    delete(move_from_btn)
    delete(move_to_btn)
end

f.UserData = f.UserData.Old;
update_tasks_panel(f,opts,'normal')

% save and finish
autosave_tasks(f,opts)

f.Pointer = 'arrow';drawnow
end

function disp_settings(f,opts)
%% Display settings to be edited by user

% check for existing
settings_fig_name = ['Task Manager ',f.UserData.Name,' Settings'];
f2 = findall(groot,'Name',settings_fig_name);
switch numel(f2)
    case 1
        % show existing
        figure(f2)
    case 0
        % create new
        create_settings_subfigure(f,opts)
    otherwise
        error('Found multiple settings figures')
end
end

function create_settings_subfigure(f,opts)
%% Display Settings GUI to adjust various options grouped in tabs

% options
subfig_sz   = [775,500];
tab_w       = 110;
tab_h       = 65;
tab_FS      = 13;
cancel_w    = 70;
TabNames    = {'Colors','Task Layout','Options'};

% The last is not a real option but just to have a 'none selected' start
TabNames = [TabNames,{'Invisible'}];

% Create subfigure
f2 = uifigure('Name',['Task Manager ',f.UserData.Name,' Settings'],...
    'Position',[0,0,subfig_sz]);
f2.UserData.FigureChanged = false;
centerfig(f2)

% store current f userdata to revert to as necessary
f.UserData.Old = f.UserData;

% create button group
tb_pos = [0,0,tab_w,subfig_sz(2)];
tb = uibuttongroup(f2,'Position',tb_pos,'SelectionChangedFcn',@(~,event)disp_sub_setting(f,f2,event,opts),'Tag','Settings Button Group');
btn_pos = [0,tb_pos(4),tab_w,tab_h];
for i = 1:numel(TabNames)
    btn_pos(2) = btn_pos(2) - tab_h;
    btn = uitogglebutton(tb,'Position',btn_pos,'Text',TabNames{i},'FontSize',tab_FS);
    if i == numel(TabNames)
        btn.Visible = false;
        tb.SelectedObject = btn;
    end
end

% create display panel
ypos = 2*opts.spacer + opts.btn_h;
panel_pos = [tab_w,ypos,subfig_sz-[tab_w,ypos]]; 
uipanel(f2,'Tag','Display','Position',panel_pos)

% Close Button
btn_pos = [tab_w + opts.spacer,opts.spacer,cancel_w,opts.btn_h];
uibutton(f2,'Position',btn_pos,'Text','Cancel',...
    'ButtonPushedFcn',@(~,~)restore_and_close_settings(f,f2),...
    'FontSize',opts.fs);
f2.CloseRequestFcn = @(~,~)restore_and_close_settings(f,f2);

% Apply/Close button
btn_pos(1) = btn_pos(1) + opts.spacer + cancel_w;
btn_pos(3) = opts.btn_w;
uibutton(f2,'Position',btn_pos,...
    'ButtonPushedFcn',@(~,~)apply_and_close_settings(f,f2,opts),...
    'Visible','off','Text','Apply & Close','Tag','Apply',...
    'FontSize',opts.fs);

% Set as new default 
btn_pos([1,3]) = [btn_pos(1) + opts.spacer + opts.btn_w,opts.btn_w_l];
uibutton(f2,'Text','Set as New Default','FontSize',opts.fs,...
    'Position',btn_pos,'Tag','Set Default','Visible','off',...
    'ButtonPushedFcn',@(~,~)set_new_default_options(f,opts));

% Restore Default
btn_pos(1) = btn_pos(1) + opts.spacer + opts.btn_w_l;
uibutton(f2,'Text','Restore Default','Visible','off','Tag','Restore Default',...
    'Position',btn_pos,'ButtonPushedFcn',@(~,~)restore_default_settings(f,f2,opts));
end

function restore_and_close_settings(f,f2)
%% Cancel settings changes & close
if isvalid(f)
    f.UserData = f.UserData.Old;
end
delete(f2)
end

function apply_and_close_settings(f,f2,opts)
%% Apply settings and redraw tasks

read_duration_limits(f)
clf(f)
delete(f2)

% if autoset priority is changed on, prompt to apply retroactive
% application or not
if f.UserData.AutoSetPriority && ~f.UserData.Old.AutoSetPriority
    prompt_AutoSetPriority_Retro_App(f,opts)
    uiwait(f)
end

draw_figure(f,opts)
autosave_tasks(f,opts)
end

function set_new_default_options(f,opts)
%% Set new default options for new figures

DefaultSettings = f.UserData;
save(opts.data_filename,'DefaultSettings','-append');
end

function disp_sub_setting(f,f2,event,opts)
%% Display a sub setting wrapper function

% show loading with pointer
f2.Pointer = 'watch';drawnow

% Change enbolded text
event.OldValue.FontWeight = 'normal';
event.NewValue.FontWeight = 'bold';

% delete whats currently on display panel
pan_obj = findobj(f2,'Tag','Display');
delete(pan_obj.Children)

% Display page
switch event.NewValue.Text
    case 'Colors'
        disp_colors(f,f2,opts)
    case 'Options'
        disp_options(f,f2,opts)
    case 'Task Layout'
        disp_task_layout(f,f2,opts)
    otherwise
        error('elseif err')
end
f2.Pointer = 'arrow';
end

function disp_colors(f,f2,opts)
%% Display color options and Urgency Limits

% Color list:
% =======================================================
% complete                  block   r   g   b
% incomplete, No Due Date   block   r   g   b
% -------------------------------------------------------
% Days left     3 days      block   r   g   b   delete copy
% Days left     2 weeks     block   r   g   b   delete copy
% -------------------------------------------------------
% More Than                 block   r   g   b
% =======================================================

% options
banner_h = 40;
banner_w = 200;
banner_fs = 18;

% need to delete display panel objects inside fnct because of add/delete
% limit option
pan_obj = findobj(f2,'Tag','Display');
delete(pan_obj.Children)

ypos = pan_obj.Position(4) - 2*opts.spacer - banner_h;

uilabel(pan_obj,"Text","Edit Urgency Limits",'Position',[opts.spacer,ypos,banner_w,banner_h],...
    'FontSize',banner_fs);

f2.UserData.ypos = ypos;

add_color_line(f,f2,'Complete',opts); 
add_color_line(f,f2,'Incomplete',opts); 
add_color_limits(f,f2,opts);
add_color_line(f,f2,'PastDue',opts)
add_color_line(f,f2,'Default',opts);
add_color_line(f,f2,'Folder',opts);
add_color_line(f,f2,'Deleted',opts);
end

function add_color_line(f,f2,Color_Name,opts,limits_ind)
%% Supporting function for function disp_colors

% Set y position
f2.UserData.ypos = f2.UserData.ypos - opts.spacer - opts.clr_h;
ypos = f2.UserData.ypos;

pan_obj = findobj(f2,'Tag','Display');

% Name
uilabel(pan_obj,'Position',[opts.spacer,ypos,opts.btn_w,opts.btn_h],...
    'Text',Color_Name,'FontSize',opts.clr_fs,'VerticalAlignment','bottom');

% Duration
if exist('limits_ind','var')
    color_access_str = ['f.UserData.Limits(',num2str(limits_ind),').Color'];
    draw_duration_objs(pan_obj,f,ypos,limits_ind,opts)
    draw_add_and_delete(f,f2,ypos,limits_ind,opts)
else
    color_access_str = ['f.UserData.',lower(Color_Name),'_clr'];
end
   
% color block and RGB
add_color_objects(f,pan_obj,color_access_str,ypos,opts)

if exist('limits_ind','var')
    % add delete option
end
end

function draw_duration_objs(pan_obj,f,ypos,limits_ind,opts)
%% Draw Duration Objects to gui color line in settings

% Part 1) draw duration for 'days left'
xpos = opts.clr_name_w;
 
% Duration Value textarea
num_pos = [xpos,ypos,opts.num_w_l,opts.num_h_l];
uitextarea(pan_obj,'Value',f.UserData.Limits(limits_ind).DurationVal,...
    'Position',num_pos,'ValueChangedFcn',@(tx,~)set_limit_dur(f,tx,limits_ind,'Val'),...
    'WordWrap','off','FontSize',opts.clr_fs);

% duration String dropdown
xpos = xpos + opts.num_w_l;
dir_pos = [xpos,ypos,opts.dur_w_l,opts.num_h_l];
uidropdown(pan_obj,'Position',dir_pos,...
    'Items',opts.DurationItems,...
    'Value',f.UserData.Limits(limits_ind).DurationStr,...
    'ValueChangedFcn',@(dr,~)set_limit_dur(f,dr,limits_ind,'Str'),...
    'FontSize',opts.clr_fs);
end

function set_limit_dur(f,obj,limits_ind,option)
%% Set the duration value or string from gui value change
if iscell(obj.Value)
    value = obj.Value{1};
else
    value = obj.Value;
end
f.UserData.Limits(limits_ind).(['Duration',option]) = value;

f2 = obj.Parent.Parent;
HasChanged(f2)
end

function draw_add_and_delete(f,f2,ypos,limit_ind,opts)
%% Add Two button icons for delete and add copy to 'colors' settings row

pan_obj = findobj(f2,'Tag','Display');

% x position
xpos = opts.icon_objects_x0;

% button sizing
btn_sz = repmat(opts.btn_h_l,1,2);

% Loop - Button Creation
Icons = {'trash.png','plus.png'};
CallBacks = {@(~,~)delete_limit(f,f2,limit_ind,opts),@(~,~)copy_and_add_limit(f,f2,limit_ind,opts)};
for i = 1:2
    uibutton(pan_obj,'Position',[xpos,ypos,btn_sz],'Text','','Icon',Icons{i},...
        'ButtonPushedFcn',CallBacks{i});
    xpos = xpos + btn_sz(1) + opts.spacer;
end
end

function delete_limit(f,f2,limit_ind,opts)
%% Remove Limit duration and color objects, redraw
f.UserData.Limits = f.UserData.Limits([1:limit_ind-1,limit_ind+1:end]);
read_duration_limits(f)
disp_colors(f,f2,opts)
HasChanged(f2)
end

function copy_and_add_limit(f,f2,limit_ind,opts)
%% Copy and add limit and color info to new limit row, redraw
f.UserData.Limits = f.UserData.Limits([1:limit_ind,limit_ind:end]);

% increase duration value by 1 by default

durval = f.UserData.Limits(limit_ind+1).DurationVal; % brevity
f.UserData.Limits(limit_ind+1).DurationVal = num2str(str2double(durval)+1);
f.UserData.Limits(limit_ind+1).Color = f.UserData.Limits(limit_ind+1).Color * .9;

% read in value
read_duration_limits(f)

% redraw panel
disp_colors(f,f2,opts)

HasChanged(f2)
end

function add_color_objects(f,pan_obj,color_access_str,ypos,opts) 
%% Add Color Objects (Filled button, 1x3 RGB uitextares)

xpos            = opts.color_objects_x0;
color0          = eval(color_access_str);
btn_square_size = opts.clr_h; 

% Button with color (opens panel, basic for now)
btn_pos = [xpos,ypos,btn_square_size,btn_square_size];
btn = uibutton(pan_obj,'Position',btn_pos,'Text','','BackgroundColor',color0,...
    'ButtonPushedFcn',@(btn,~)color_prompt(pan_obj,btn,color_access_str,opts));

% (quadruple spacer here)
xpos = xpos + btn_square_size + 4*opts.spacer;
% R G B uilabel + uitextarea
Tags = {'R','G','B'};
tx_pos = [xpos,ypos,opts.num_w,opts.num_h_l];
for i = 1:3
    % label
    uilabel(pan_obj,'Position',tx_pos,'Text',Tags{i},...
        'FontSize',opts.clr_fs,'VerticalAlignment','bottom');
    tx_pos([1,3]) = [tx_pos(1) + opts.num_w,opts.num_w_xl];
    % text area
    uitextarea(pan_obj,'Position',tx_pos,'Value',num2str(round(color0(i),opts.rgb_int_round)),...
        'Tag',[color_access_str,' ',Tags{i}],'WordWrap','off',...
        'ValueChangedFcn',@(tx,~)set_rgb_value(f,tx,btn,color_access_str,i),...
        'FontSize',opts.clr_fs);  %,'VerticalAlignment','bottom');
    tx_pos([1,3]) = [tx_pos(1) + opts.num_w_xl + opts.spacer,opts.num_w];
end
end

function color_prompt(pan_obj,btn,color_access_str,opts) 
%% Prompt color options and reflect selection to proper rgb textareas

color = uisetcolor;
figure(pan_obj.Parent)

% early exit case
if numel(color) == 1
    return
end

btn.BackgroundColor = color;

% find text objects for rbg display
Tags = {'R','G','B'};
for i = 1:3
    Tag = [color_access_str,' ',Tags{i}];
    tx_obj = findobj(pan_obj,'Tag',Tag);
    tx_obj.Value = num2str(round(color(i),opts.rgb_int_round));
end

% set color in main figure userdata
eval([color_access_str,' = color;'])

f2 = pan_obj.Parent;
HasChanged(f2)
end

function HasChanged(f2)
%% set and reflect that figure input has been accetped
if ~f2.UserData.FigureChanged
    f2.UserData.FigureChanged = true;

    % Show settings buttons working with changes
    btn         = findobj(f2,'Tag','Apply');
    btn.Visible = true;
    btn         = findobj(f2,'Tag','Set Default');
    btn.Visible = true;
    btn         = findobj(f2,'Tag','Restore Default');
    btn.Visible = true;
end
end

function set_rgb_value(f,tx,btn,color_access_str,rgb_ind) %#ok<INUSD>
%% Read in change to RGB value of given color, reflect change in f.UserData

% ~~~ Add a check for num2str ~= NaN for bad digit entry

eval([color_access_str,'(',num2str(rgb_ind),') = ',tx.Value{1},';'])

% 1 vs 255 issue
num = str2double(tx.Value{1});
if num > 1
    num = num/255;
end
% reflect in button
btn.BackgroundColor(rgb_ind) = num;

f2 = tx.Parent.Parent;
HasChanged(f2)
end

function add_color_limits(f,f2,opts)
%% Add series of color lines based on Limits input
for ind = 1:numel(f.UserData.Limits)
    add_color_line(f,f2,'Due in',opts,ind)
end
end

function disp_options(f,f2,opts)
%% Show editable options in settings

pan_obj = findobj(f2,'Tag','Display');

% Banner :
% position is uppr 15%, horizontally centered
banner_y_ratio  = .15;  % top 15% of panel
banner_y0   = pan_obj.Position(4)*(1-banner_y_ratio);
banner_y    = pan_obj.Position(4)*banner_y_ratio;
banner_pos  = [0,banner_y0,pan_obj.Position(3),banner_y];

uilabel(pan_obj,'Text','Options','FontSize',opts.ban_fs,...
    'Position',banner_pos,'HorizontalAlignment','center',...
    'VerticalAlignment','center');

flags(1).name = 'Auto-Set Priority';
flags(1).desc = 'Automatically set completed tasks lesser in priority to incomplete tasks upon adding and completing tasks';

display_flags(f,f2,flags,pan_obj,banner_y0,opts)
end

function add_completion_mode_option(f,pan_obj,ypos_0,opts)
%% Add Option to complete tasks manually or as groups (to options settings)

f2 = pan_obj.Parent;
% label

option_h    = opts.btn_h;
lb_w        = 140; % label width
ypos        = ypos_0 - option_h - opts.spacer;
lb_pos      = [opts.spacer,ypos,lb_w,option_h];
uilabel(pan_obj,'Text','Task Completion Mode:','FontSize',opts.fs,...
    'Position',lb_pos);

% Options button group

xpos            = opts.spacer + lb_w;
btn(1).w        = 65;
btn(1).tx       = 'Manual';
btn(1).ToolTip  = 'All tasks are manually completed';
btn(2).w        = 88;
btn(2).tx       = 'By SubTask';
btn(2).ToolTip  = 'Tasks are always and only completed when all subtasks are completed, if they exist';
btn_gp_w        = 3*opts.spacer + sum([btn.w]);
btn_gp_pos      = [xpos,ypos,btn_gp_w,option_h];
btn_gp          = uibuttongroup(pan_obj,'Position',btn_gp_pos,...
     'SelectionChangedFcn',@(~,event)set_completion_mode(f,f2,event));

% Options buttons
xpos = opts.spacer + [0,btn(1).w];
for i = 1:2
    uiradiobutton(btn_gp,'Position',[xpos(i),0,btn(i).w,opts.btn_h],...
        'Text',btn(i).tx,'FontSize',opts.fs,...
        'Tooltip',btn(i).ToolTip);
end

% Set to current userdata value ~~~ why do I feel like there must be a
% better way to do this haha
btn_gp.SelectedObject = btn_gp.Children(strcmpi({btn_gp.Children.Text},f.UserData.CompletionMode));
end

function set_completion_mode(f,f2,event)
%% Sets task completion mode setting in 'options' (call back to radio button)
f.UserData.CompletionMode = event.NewValue.Text;
HasChanged(f2)
end

function disp_task_layout(f,f2,opts)
%% Show and modify task layout options

% remove old objects
p = findobj(f2,'Tag','Display');

% draw banner
ban_str     = 'Task Layout Options';
ban_ypos    = p.Position(4) - opts.spacer - opts.ban_h;
ban_pos     = [0,ban_ypos,p.Position(3),opts.ban_h];
uilabel(p,'Text',ban_str,'FontSize',opts.ban_fs,'Position',ban_pos,...
    'HorizontalAlignment','center');

% draw example task
update_tasks_panel(f,opts,'example')

% find resulting y position
ypos = ban_ypos - opts.spacer - f.UserData.Tasks(opts.max_num_tasks).Height;

% ~~~ whoops I'm retarded you can just include text in the checkbox
% Inlcude options: (date created, due date, Type, regularity,...)
for i = opts.OptionalFields
    % y-position
    ypos = ypos - opts.spacer - opts.btn_h;
    
    FieldName = replace(i{1},' ','');

    % label 
    uilabel(p,'Text',i{1},'FontSize',opts.fs,...
        'Position',[opts.spacer,ypos,opts.btn_w_l,opts.btn_h]);
    % checkbox
    uicheckbox(p,'Position',[2*opts.spacer + opts.btn_w_l,ypos,opts.btn_w_l,opts.btn_h],...
        'Value',f.UserData.Show.(FieldName),'Text','Show',...
        'ValueChangedFcn',@(chbx,~)toggle_task_field_inclusion(f,f2,FieldName,opts,chbx));
end

DescFontWeight_flag = strcmpi(f.UserData.DescFontWeight,'bold');
ypos = ypos - opts.spacer - opts.btn_h;
uicheckbox(p,"Value",DescFontWeight_flag,'Text','Task Name Emboldened',...
    'ValueChangedFcn',@(chbx,~)toggle_task_name_weight(f,f2,chbx,opts),...
    'Position',[opts.spacer,ypos,400,opts.btn_h],...
    'FontSize',opts.fs);
end

function toggle_task_field_inclusion(f,f2,FieldName,opts,chbx)
%% Change whether a given task field is displayed and reflect to example

% ~~~ Funny problem here. If the example task gets bigger, then the
% checkboxes get overlapped. We need to do something about that

f2.Pointer = 'watch';drawnow

% Set Show flag according to input
f.UserData.Show.(FieldName) = chbx.Value;

% redraw example task
update_tasks_panel(f,opts,'example')

% set changes to applicable and resettable
HasChanged(f2)

f2.Pointer = 'arrow';drawnow
end

function toggle_task_name_weight(f,f2,chbx,opts)
%% Reflect change in task name font weight, redraw example task

f2.Pointer = 'watch';drawnow

% set font weight flag
if chbx.Value
    f.UserData.DescFontWeight = 'bold';
else
    f.UserData.DescFontWeight = 'normal';
end

% redraw
update_tasks_panel(f,opts,'example')

% set changes to applicable and resettable
HasChanged(f2)

f2.Pointer = 'arrow';drawnow
end

function Tasks = read_task_layout(f,Tasks,Task_ind,opts)
%% Read Task Layout Show Flags and Designate Component and Task Heights

Show = f.UserData.Show;

for ind = Task_ind

    % initialize show vector for all optional fields
    num = length(opts.OptionalFields);
    show_vector = zeros(num,1);

    % combine user show options with optional field conditions, return tf vector
    opt_fields = replace(opts.OptionalFields,' ','');
    for i = 1:numel(opt_fields)
        show_vector(i) = Show.(opt_fields{i}) && opts.OptionalFieldsConditions{i}(Tasks(ind));
        Tasks(ind).Show.(opt_fields{i}) = show_vector(i);
    end

    % use sum to deinfe height positions
    for i = 1:num
        num_elements_after = sum(show_vector(i+1:num));
        ypos = opts.spacer + opts.lbl_h*num_elements_after;
        Tasks(ind).([opt_fields{i},'Height']) = ypos;
    end
    Tasks(ind).Height = (sum(show_vector) + 1) * opts.lbl_h + 2*opts.spacer;
end
end 

function add_task_ind = get_add_task_ind_from_f2(f2,opts)
%% Return number of new tasks from add task subfigure (using isempty)

if ~f2.UserData.isExpanded
    add_task_ind = 1;
    return
end

add_isempty = true(opts.num_add_tasks,1);
for ind = 1:opts.num_add_tasks
    tx_obj = findobj(f2,'Tag',['Task Name',num2str(ind)]);
    add_isempty(ind) = isempty(tx_obj.Value{1});
end

add_task_ind = find(~add_isempty);
end

function add_statistics_panel(f,opts)
%% Display TM file statsitics (num tasks, num completed, etc)


f.UserData.y0 = f.UserData.y0 - opts.stat_pan_h - opts.spacer;
panel_pos = [opts.spacer,f.UserData.y0,opts.left_pan_w,opts.stat_pan_h];

% create panel
stats_pan = uipanel(f,'Tag','Statistics Panel','Position',panel_pos);

% Contents : I'm thinking total, completed, past due, due this week??
% ^ ~~~ lets just start with the three, revisit later

Names = ["Existing Tasks","Existing Folders","Completed Tasks","Incomplete Tasks","Displayed Tasks","Tasks Past Due","Deleted Tasks"];
Value_w = 30; % width allocated to value label
Name_w = opts.left_pan_w - opts.spacer - Value_w; % remaining width for name label
%Name_w = 100; % leaving space

% create 2 uilabels for each statistic, 1 for name and 1 for value (tagged)

y0 = opts.stat_pan_h - opts.spacer;
for Name = Names
    y0 = y0 - opts.tx_h - opts.spacer;
    % create name label 
    uilabel(stats_pan,'Text',Name,'Position',[opts.spacer,y0,Name_w,opts.tx_h]);

    % create value label
    uilabel(stats_pan,'Text','','Tag',Name,...
        'Position',[Name_w,y0,Value_w,opts.tx_h]);
end
end

function update_stats_pan(f)
%% Update the Task counts in the statitics panel 

%  speed comparison commented out (panel was quicker)

% disp('finding labels from figure')
% tic
% All_label = findobj(f,'Tag','All Tasks');
% Complete_label = findobj(f,'Tag','Completed Tasks');
% Past_label = findobj(f,'Tag','Tasks Past Due');
% toc

% disp('finding labels from panel')
% tic
stat_pan        = findobj(f,'Tag','Statistics Panel');
exist_label     = findobj(stat_pan,'Tag','Existing Tasks');
folder_label    = findobj(stat_pan,'Tag','Existing Folders');
Complete_label  = findobj(stat_pan,'Tag','Completed Tasks');
Incomplete_label= findobj(stat_pan,'Tag','Incomplete Tasks');
Past_label      = findobj(stat_pan,'Tag','Tasks Past Due');
Displayed_label = findobj(stat_pan,'Tag','Displayed Tasks');
Deleted_label   = findobj(stat_pan,'Tag','Deleted Tasks');
% toc

if f.UserData.NumTasks == 0
    exits       = 0;
    folders     = 0;
    completed   = 0;
    incomplete  = 0;
    past        = 0;
    displayed   = 0;
    deleted     = 0;
else
    % All label
    % ~~~ should this be all tasks? displayed? not deleted?
    % ^ I am going to say not deleted for now.

    Tasks       = f.UserData.Tasks(1:f.UserData.NumTasks);
    isTask      = ~[Tasks.isFolder];

    alive       = isTask & ~[Tasks.Deleted];
    exits       = numel(find(alive));

    alive_f     = ~isTask & ~[Tasks.Deleted];
    folders     = numel(find(alive_f));

    completed   = [Tasks.Completed] & alive;
    completed   = numel(find(completed));

    incomplete  = ~[Tasks.Completed] & alive;
    incomplete  = numel(find(incomplete));

    past        = [Tasks.PastDue] & alive;
    past        = numel(find(past));

    displayed   = numel(find(isDisplayed(f.UserData,find(isTask))));

    deleted     = numel(find([Tasks.Deleted]));
end

% assign values to label
exist_label.Text        = num2str(exits);
folder_label.Text       = num2str(folders);
Complete_label.Text     = num2str(completed);
Incomplete_label.Text   = num2str(incomplete);
Past_label.Text         = num2str(past);
Displayed_label.Text    = num2str(displayed);
Deleted_label.Text      = num2str(deleted);
end

function autosave_warning(self,f)
%% Display warning to inform pro's and con's of autosave
f.Pointer = 'watch';drawnow

% let 'em know it's serious
warndlg(sprintf(['With Autosave mode off, you are liable to lose any work that has not been manually saved.\n',...
    'With Autosave mode on, the program runs less efficinetly, espeically with a large amount of displayed tasks.']))

% set new value in userdata to refer to quickly
f.UserData.Autosave = strcmpi(self.Value,'on');

f.Pointer = 'arrow';drawnow
end

function keyboard_shortcuts(event,Shortcut,CallBack)
%% Execute shortcus for uifigure 

if ~isempty(event.Modifier) && strcmp(event.Modifier,'control') && ~isempty(event.Character)
    % Main Figure Shortcuts
    [present,ind] = ismember(event.Character,Shortcut);
    if present
        CallBack{ind}()
    end
end
end

function Task = store_task_objects(parent_panel,Task,task_ind,opts)
%% Store various uiobjects to user data tasks strcut array to reference quickly for update

% ~~~ is this stupid?? I feel like it may be. COuldnt this be done in task
% drawing? I think it should be lol

% panel
Task.Labels.Panel = findobj(parent_panel,'Tag',['Task ',num2str(task_ind)]);

% description
Task.Labels.Description = findobj(parent_panel,'Tag',['description ',num2str(task_ind)]);

% due date
Task.Labels.DueDate = findobj(parent_panel,'Tag',['Due Date ',num2str(task_ind)]);

% move to
Task.Labels.MoveTo = findobj(parent_panel,'Tag',['Move to ',num2str(task_ind)]);

% move from
Task.Labels.MoveFrom = findobj(parent_panel,'Tag',['Move from ',num2str(task_ind)]);

% optional fields
for vars = opts.OptionalFields
    lbl_obj = findobj(parent_panel,'Tag',[vars{1},' ',num2str(task_ind)]);

    field_str = replace(vars{1},' ','');
    Task.Labels.(field_str) = lbl_obj;
end

% collpase icon
Task.Labels.Collapse = findobj(parent_panel,'Tag',['Collapse ',num2str(task_ind)]);

Task.isDrawn = true; % ~~~ kind of weird place to put this but makes snese becuase we are resaving the task to f.UserData here anyway
end

function UserData = rmv_gui_objects(UserData)
%% Remove GUI Objects from UserData before saving
for ind = 1:UserData.NumTasks
    UserData.Tasks(ind).Labels = [];
end
end

function UserData = store_previous_tasks(UserData)
%% Store Old data (filtered) to current data fro restoration
% if isfield(UserData,'Old')
%     UserData = rmfield(UserData,'Old');
% end
UserData.Old = UserData;
% This is only its own function because of since-removed extra
% functionality. Easier to leave as a shared call for now but not necessary
% any longer. Just FYI.
end

function UserData = clear_UserData_isDrawn(UserData,opts)
%% Declare isDrawn false for all tasks upon reloading figure
for i = [1:UserData.NumTasks,opts.max_num_tasks]
    UserData.Tasks(i).isDrawn = false;
end
end

function quick_comment_close(f,Task_ind,opts,event)
%% TBD
% ~~~ This funciton does not work. Bummer. There seems to be a lot of
% lmitations with the keypressfcn of the matlab guis. 
% ~~~ do you remember the time I got the new version of matlab and it
% solved one of my ui problems??
% What problem was that..
% I cant remember, was a little over a year ago I think. Which means
% there's a new version. Lets try it. 

if numel(event.Value) > 1
    event.Source.Value = event.Value{1};
    edit_comment(f,Task_ind,opts)
end
end

function convert_task_item(f,f2,task_ind,opts)
%% Change task vs. folder status

% save old data
f.UserData.Old = f.UserData; % ~~~ I am now inconsistent here :/ but I like this better for now. The other would be easier to edit but I think unnecessary for now. We'll see

% toggle status
f.UserData.Tasks(task_ind).isFolder = ~f.UserData.Tasks(task_ind).isFolder;
Task = f.UserData.Tasks(task_ind);

% so I can find the edit button switch the call option here, or do it in
% update tasks. I think here is better, I suppose.

% hide completion button for folders
if Task.isFolder
    edit_str        = 'edit folder';
    complete_visible = false;
    % check for completion based on new status
    if (~Task.Completed && ~isempty(Task.SubTasks) && isComplete_folder(f,task_ind)) ||...
       (Task.Completed && ~isComplete_folder(f,task_ind)) 
        toggle_complete_task_wrapper(f,task_ind,opts);
    end
else
    edit_str = 'edit task';
    complete_visible = true;
end

f.UserData.Tasks(task_ind).Labels.TaskBtns(1).Visible = complete_visible;

task_edit_btn = findobj(f.UserData.Tasks(task_ind).Labels.Panel,'Tag',['Edit Item ',num2str(task_ind)]);
task_edit_btn.ButtonPushedFcn = @(~,~)add_task_gui(f,task_ind,opts,edit_str);

delete(f2)
update_tasks_panel(f,opts,'normal')
autosave_tasks(f,opts)
end

function tf = isComplete_folder(f,Task_ind)
%% check if all alive subtasks of folder are completed
% alive as in not deleted

Task = f.UserData.Tasks(Task_ind);

% N/A for task items, only folder items
if ~Task.isFolder
    tf = false;
    return
end

% check completion & deletion status of task
subtasks = f.UserData.Tasks(Task.SubTasks);

isAlive = ~[subtasks.Deleted];
if all([subtasks(isAlive).Completed])
    tf = true;
else
    tf = false;
end
end

function collapse_btn = add_collapse_icon(f,parent_panel,Task,task_ind,opts)
%% Draw icon for collapsing sub-items of folders

if Task.Collapsing
    collapse_icon = 'collapsed.png';
else
    collapse_icon = 'uncollapsed.jpg';
end

origin = collapse_position([Task.xpos,Task.ypos],Task.Height,opts);
pos = [origin,opts.collapse_sz,opts.collapse_sz];
collapse_btn = uibutton(parent_panel,'Tag',['Collapse ',num2str(task_ind)],...
    'Position',pos,'Text','','Icon',collapse_icon,...
    'ButtonPushedFcn',@(self,~)toggle_collapse(f,self,task_ind,opts),...
    'BackgroundColor',opts.task_pan_clr);
end

function toggle_collapse(f,self,task_ind,opts)
%% Toggle the collapsing status of a folder 

f.Pointer = 'watch';

% collapsing on or off boolean
Collapsed = ~f.UserData.Tasks(task_ind).Collapsing;

% set collapsing
f.UserData.Tasks(task_ind).Collapsing = Collapsed;

% set sub-item collapsed
collapse_subtasks(f,task_ind,Collapsed)

% switch icon
if Collapsed
    collapse_icon = 'collapsed.png';
else
    collapse_icon = 'uncollapsed.jpg';
end

self.Icon = collapse_icon;

update_tasks_panel(f,opts,'normal')
autosave_tasks(f,opts)
f.Pointer = 'arrow';
end

function collapse_subtasks(f,task_ind,Collapsed)
%% Recursively set collapse flag to task subtasks

subtasks = f.UserData.Tasks(task_ind).SubTasks;
if isempty(subtasks)
    return 
end

for ind  = subtasks
    f.UserData.Tasks(ind).Collapsed = Collapsed;

    % collapse recursive (except for collapsing)
    if ~f.UserData.Tasks(ind).Collapsing
        collapse_subtasks(f,ind,Collapsed)
    end
end
end

function pos = collapse_position(panel_pos,Task_Height,opts)
%% Return collapse icon origin (1x2) from task panel position 
pos = panel_pos - [opts.collapse_sz + opts.spacer,(opts.collapse_sz-Task_Height)/2];
end

function lbl_str = DueDate_lbl_str(Task,opts)
%% Return the exact string used fo rhte uilabel for a given task

if isdatetime(Task.DueDate)
    datestr = char(Task.DueDate,opts.DateFormat);
else
    datestr = Task.DueDate;
end
lbl_str = ['Due Date: ',datestr];
end

function set_default_duedate(f,self)
%% Set default manager due date from uitextarea
f.UserData.DefaultDueDate = self.Value;
end

function display_flags(f,f2,flags,pan_obj,ypos,opts)
%% Display user-setting flags with on/off uiswitch
tx_l    = 120;
uisw_w  = 85;

% general label and switch positions
lbl_pos = [opts.spacer,0,tx_l,opts.tx_h];
sw_pos  = [2*opts.spacer + tx_l,0,uisw_w,opts.tx_h];

for flag = flags
    % move ypos down
    ypos = ypos - opts.tx_h-opts.spacer;
    lbl_pos(2) = ypos;
    sw_pos(2)  = ypos;

    % name label
    uilabel(pan_obj,'Position',lbl_pos,'Text',flag.name,'Tooltip',flag.desc);

    % switch
    real_name = replace(flag.name,{'-',' '},'');
    if f.UserData.(real_name)
        Value = 'On';
    else
        Value = 'Off';
    end
    uiswitch(pan_obj,'Position',sw_pos,'Value',Value,'ValueChangedFcn',@(~,self)assign_flag_value(f,f2,self,real_name));
end
end

function assign_flag_value(f,f2,self,real_name)
%% Store value from uiswitch to userdata flags
if strcmpi(self.Value,'on')
    f.UserData.(real_name) = true;
else
    f.UserData.(real_name) = false;
end
HasChanged(f2)
end

function prompt_AutoSetPriority_Retro_App(f,opts)
%% Prompt user to apply autoset priority change retroactivley 

dlg_w = 650;
btn_w = 200;

height = 3*opts.spacer + 2*opts.btn_h;
width = 2*opts.spacer + dlg_w;
f2 = uifigure;
f2.Position(3:4) = [width,height];
centerfig(f2)
f2.CloseRequestFcn = @(~,~) close_autoset_retro_app(f,f2);

% dialog
lbl_pos = [opts.spacer,2*opts.spacer+opts.btn_h,dlg_w,opts.btn_h];
lbl_txt = "Auto-Set Priority mode turned on for new tasks. Would you like to apply priority setting retro-actively to existing tasks?";
uilabel(f2,'Position',lbl_pos,'Text',lbl_txt)

% btn 1 - yes
btn_txt = "Apply Retroactively";
btn_pos = [opts.spacer,opts.spacer,btn_w,opts.btn_h];
uibutton(f2,'Position',btn_pos,'Text',btn_txt,'ButtonPushedFcn',@(~,~)AutoSetPriority_Retro_app(f,f2))

% btn 2 - no
btn_txt = "Don't change existing task priority";
btn_pos(1) = 2*opts.spacer + btn_w;
uibutton(f2,'Position',btn_pos,'Text',btn_txt,'ButtonPushedFcn',@(~,~)close(f2))
end

function AutoSetPriority_Retro_app(f,f2)
%% Apply retroactive priority changing to place completed tasks below incomplete tasks
f2.Pointer = 'watch';drawnow

Tasks = f.UserData.Tasks;

% find every group of subtasks and re-arrange according to completion
for task_ind = 1:f.UserData.NumTasks
    subtasks = Tasks(task_ind).SubTasks;
    if numel(subtasks) < 2
        continue
    end

    % break into completed and incomplete subtasks
    compl  = subtasks([Tasks(subtasks).Completed]);
    incomp = subtasks(~[Tasks(subtasks).Completed]);

    if isempty(compl) || isempty(incomp)
        continue
    end

    % find highest (in rank number) priority for incomplete tasks
    [Incomp_max_priority,switch_ind] = max([Tasks(incomp).Priority]);
    move_to_ind = incomp(switch_ind);

    % find completed tasks with priorities lower than highest
    % incomplete
    all_move_down_ind = compl([Tasks(compl).Priority] < Incomp_max_priority);
    for move_down_ind = all_move_down_ind
        f.UserData.move_from_ind   = move_down_ind;
        f.UserData.moving_siblings = subtasks(subtasks ~= move_down_ind);
        move_priority(f,move_to_ind,[],'auto')
    end
end
close(f2)
end

function close_autoset_retro_app(f,f2)
%% close dialog nd resume settings update after autoset priority prompt
if isvalid(f)
    uiresume(f)
end
delete(f2)
end

function set_default_settings(f,opts)
%% Set default figure settings, either from options or saved file

warning off
if exist(opts.data_filename,'file')
    LoadedStruct = load(opts.data_filename,'DefaultSettings');
    if isempty(fieldnames(LoadedStruct))
        % if Default Settings havent been saved off, use default default
        % settings
        default_struct = opts.DefaultSettings;
    else
        % use custom default settings
        default_struct = LoadedStruct.DefaultSettings;
    end
else
    % if Default Settings havent been saved off, use default default
    % settings
    default_struct = opts.DefaultSettings;
end
warning on

for field = fieldnames(opts.DefaultSettings)'
    f.UserData.(field{1}) = default_struct.(field{1});
end

% Read in duration limits
read_duration_limits(f)
end

function restore_default_settings(f,f2,opts)
%% Restore default settings (not much else to say here)

f2.Pointer = 'watch'; drawnow

% overwrite userdata with default settings
set_default_settings(f,opts)

% delete whats currently on display panel
pan_obj = findobj(f2,'Tag','Display');
delete(pan_obj.Children)

% find option
bg = findobj(f2,'Tag','Settings Button Group');

% re-draw page page
switch bg.SelectedObject.Text
    case 'Colors'
        disp_colors(f,f2,opts)
    case 'Options'
        disp_options(f,f2,opts)
    case 'Task Layout'
        % need to tell update script that the example task needs to be
        % drawn again
        f.UserData.Tasks(opts.max_num_tasks).isDrawn = false;

        disp_task_layout(f,f2,opts)
    otherwise
        error('elseif err')
end
f2.Pointer = 'arrow'; drawnow
end

function move_place_holder_panel(parent_panel,Tasks,opts)
%% Create or move placeholder panel on task panel to add space on top task

% ~~~ seems really weird that I have to do this. but dont know the better
% way as of now.

if isempty(Tasks)
    return
end

placeholder = findobj(parent_panel,'Tag','placeholder');
if isempty(placeholder)
    initial_pos = [0,0,parent_panel.Position(3),opts.spacer];
    placeholder = uipanel(parent_panel,'Tag','placeholder',...
        'Position',initial_pos,...
        'BackgroundColor',parent_panel.BackgroundColor,'BorderType','none');
end

% find placeholder height
[max_height,task_ind]   = max([Tasks.ypos]);
placeholder.Position(2) = max_height + Tasks(task_ind).Height;
end

function exit_task_manager(f,opts)
%% Close request function for main figure

% prompt unsaved data changes subfigure
if f.UserData.UnsavedChangesPresent
    unsaved_changes_prompt(f,opts)
    return
end

%% Close subfigures
% ~~~ I think there's a better way to do this. Dont care to find it right now

% find and close settings subfigure
settings_fig_name = ['Task Manager ',f.UserData.Name,' Settings'];
f2 = findall(groot,'Name',settings_fig_name);
close(f2)

% find and close any add or edit task GUIs
fig_Tag = ['Task Manager ',f.UserData.Name,' Add/Edit Task'];
f2 = findall(groot,'Tag',fig_Tag);   
close(f2)

% find and close recent activity subfigure
f2 = findall(groot,'Name',['Task Manager ',f.UserData.Name,' Recent Activity']);
close(f2) 

% close main figure
delete(f)
end

function unsaved_changes_prompt(f,opts)
%% Prompt user to save changes before exiting task manager

% create figure
width = 500;
height = opts.spacer*3 + opts.btn_h + opts.tx_h;
f2 = uifigure('Name','Unsaved Changes Warning','Position',[0,0,width,height]);
centerfig(f2)

% Warning description
desc = 'There are unsaved changes to this Task Manager. Do you want to save them before exiting?';
lbl_pos = [0,2*opts.spacer + opts.btn_h,width,opts.tx_h];
uilabel(f2,'Text',desc,'Position',lbl_pos,'HorizontalAlignment','center');

% button 1: Save & Close
btn_pos = [opts.spacer,opts.spacer,opts.btn_w,opts.btn_h];
uibutton(f2,'Text','Save & Close','Position',btn_pos,...
    'ButtonPushedFcn',@(~,~)save_and_exit(f,f2,opts));

% button 2: Close without saving
btn_pos(1) = 2*opts.spacer + opts.btn_w;
btn_pos(3) = 1.5*opts.btn_w;
uibutton(f2,'Text','Exit Without Saving','Position',btn_pos,...
    'ButtonPushedFcn',@(~,~)exit_without_saving(f,f2));

% button 3: Cancel
btn_pos(1) = width - opts.btn_w - opts.spacer;
btn_pos(3) = opts.btn_w;
uibutton(f2,'Text','Cancel','Position',btn_pos,...
    'ButtonPushedFcn',@(~,~)close(f2));
end

function save_and_exit(f,f2,opts)
%% Save task manager and exit upon prompt
close(f2)
f.Pointer = 'watch';drawnow
autosave_tasks(f,opts,'override autosave enable flag')
pause(.5)
f.Pointer = 'arrow';drawnow
pause(.5)
exit_task_manager(f,opts)
end

function exit_without_saving(f,f2)
%% exit task manager upon prompt with unsaved changes

% pretend that there are no unsaved changes and call the close request
% function again
close(f2)
f.UserData.UnsavedChangesPresent = false;
exit_task_manager(f)
end

function show_recent_activity(f,opts)
%% Create subfigure to show recent task completion/creation over past time ranges

% elements : 
% - uitabgroup, with each tab containing:
%   - Total tasks completed, with names and dates when applicable
%   - "", but for tasks created
%   - anything for deleted? edited? commented? ~~~ *** 

% disp totals in sentence (created, completed)
% disp all creation and completion events 

% ~~~ now if we wanted to, we could add a graph feature showing task
% creations, completions, and more over time for this TM. 
% ^ not a bad idea, hardly necessary, but so what? we're having fun


Tasks = f.UserData.Tasks(1:f.UserData.NumTasks);

fig_w = 750;
fig_h = 600;

% create figure
f2 = uifigure('Name',['Task Manager ',f.UserData.Name,' Recent Activity'],'Resize','off');
f2.Position(3:4) = [fig_w,fig_h];
centerfig(f2)

% add banner
uilabel(f2,"Text",'Recent Actvitiy Board','FontSize',opts.ban_fs,...
    'Position',[0,fig_h-opts.ban_h,fig_w,opts.ban_h],'HorizontalAlignment','center');

% add checkbox for including deleted items

% add uitabgroup 
tg_pos = [opts.spacer,opts.spacer,fig_w - 2*opts.spacer,fig_h - opts.ban_h - opts.spacer];
tg = uitabgroup(f2,'Position',tg_pos);

% add note about using last completion date, not included if redone
% ~~~^ add and change positions

% add tabs by duration period to tabgroup
duration_str = {'Today','Last week','Last month','Last 6 months','Last year','Custom'};
duration     = [days(1),days(7),days(31),years(1/2),years(1),days(nan)];

for d_ind = 1:numel(duration) 

    % create uitab for given duration
    t = uitab(tg,'Title',duration_str{d_ind},'Scrollable','On');

    % prompt custom timeframe (tough) ~~~ not done yet
    if strcmp(duration_str{d_ind},'Custom')
        y0 = t.InnerPosition(4) - opts.btn_h - 30;
        prompt_custom_date_range(t,Tasks,y0,opts);
        return
    else
        % if not custom, search type is "after" a minimum date of today - timerange
        SearchType  = 'after';
        date0       = datetime - duration(d_ind);
    end

    % write activity labels
    write_timed_activity(t,Tasks,date0,SearchType,false,opts);
end
end

function prompt_custom_date_range(t,Tasks,y0,opts,prev_search)
%% Create uiobject for custom date range for recent activity board

% radio button names and widths
before.name = 'before';
before.w    = 80;
after.name  = 'after';
after.w     = 70;
btween.name = 'between';
btween.w    = 95;
net_w       = before.w + after.w + btween.w;

opts.duedate_tx_w
bg = uibuttongroup(t,'Position',[opts.spacer,y0,net_w,opts.tx_h],'BorderType','none');

% radio buttons
btn_pos = [opts.spacer,0,nan,opts.tx_h];
for btn = [before,after,btween]

    % correct width
    btn_pos(3) = btn.w;

    % create button
    uiradiobutton(bg,'Text',btn.name,'Position',btn_pos);

    % move position
    btn_pos(1) = btn_pos(1) + btn_pos(3);
end

% date selection using uidatepicker here
x0      = opts.spacer + net_w;
dp1_pos = [x0,y0,opts.dpw,opts.btn_h];
dp1     = uidatepicker(t,'Position',dp1_pos);

% label and second uidaterange (visibilty conditional)
x0      = x0 + opts.dpw;
and_w   = 20;
tx      = uilabel(t,"Text",'&','Position',[x0,y0,and_w,opts.tx_h],...
    'HorizontalAlignment','center','VerticalAlignment','top','Visible','off');

x0      = x0 + and_w;
dp2     = uidatepicker(t,'Position',[x0,y0,opts.dpw,opts.btn_h],'Visible','off');

bg.SelectionChangedFcn = @(self,~)switch_date_range_option(self,tx,dp2);

% "execute search" button
btn_pos = [net_w + opts.spacer + and_w + 2*opts.dpw + opts.spacer,y0,opts.btn_w_s,opts.btn_h];
uibutton(t,'Text','Search','Position',btn_pos,'VerticalAlignment','top',...
    'ButtonPushedFcn',@(~,~)write_custom_timed_activity(t,Tasks,bg,dp1,dp2,opts))

% load previous search info if existing
if exist("prev_search",'var')
    bg.SelectedObject = findobj(bg,'Text',prev_search.SearchType);
    switch_date_range_option(bg,tx,dp2)

    dp1.Value = prev_search.date(1);
    if strcmpi(prev_search.SearchType,'between')
        dp2.Value = prev_search.date(2);
    end
end
end

function switch_date_range_option(self,tx,dp2)
%% Implement switch between 'before' 'after' and 'between' daterange options

isBetween = strcmpi(self.SelectedObject.Text,'between');
% display text and datepicker2 objects if item is set to between
tx.Visible  = isBetween;
dp2.Visible = isBetween;
end

function write_custom_timed_activity(t,Tasks,bg,dp1,dp2,opts)
%% Wrapper function to write timed activity from "custom" tab

% grab info from GUI
SearchType  = bg.SelectedObject.Text;
date        = dp1.Value;
if strcmpi(SearchType,'between')
    date    = [date,dp2.Value];
end

% clear the tab
delete(t.Children);

% write the data as requested
prompt_y0 = write_timed_activity(t,Tasks,date,SearchType,true,opts);

prev_search.SearchType  = SearchType;
prev_search.date        = date;

% write the new prompt at correct y0
prompt_custom_date_range(t,Tasks,prompt_y0,opts,prev_search)
end

function propmt_y0 = write_timed_activity(t,Tasks,date,SearchType,isCustom,opts)
%% Write uilabels with activtiy report for given time range

% find affected task indeces for given duration
if isempty(Tasks)
    Activity.created.ind    = [];
    Activity.completed.ind  = [];
    Activity.num_items      = 2;
else
    Activity = find_activity(Tasks,date,SearchType);
end

% find starting vertical position for scrollable listing (avoid any
% negative positions in panel)
y0 = find_y0(Activity.num_items,t.Position(4),isCustom,opts);

propmt_y0 = y0 + opts.btn_h;

% date, image and label positioning for each row
date_pos    = @ (y0) [opts.spacer,                               y0, opts.date_lbl_w,                opts.tx_h];
im_pos      = @ (y0) [opts.spacer + opts.date_lbl_w,             y0, opts.tx_h,                      opts.tx_h];
lbl_pos     = @ (y0) [opts.spacer + opts.date_lbl_w + opts.tx_h, y0, t.Position(3) - opts.spacer,    opts.tx_h];

% write info to tab
for action = ["created","completed"]

    % write total
    num = numel(Activity.(action).ind);
    total_str = num2str(num) + " Tasks " + action;
    uilabel(t,'Text',total_str,'Position',lbl_pos(y0));
    y0 = y0 - opts.tx_h;

    % list actions
    for ind = 1:length(Activity.(action).ind)

        task_ind    = Activity.(action).ind(ind);
        date        = Activity.(action).dates(ind);

        % write date
        uilabel(t,'Text',string(date),'Position',date_pos(y0));

        % show folder icon
        if Tasks(task_ind).isFolder
            % image source file path for folder
            IS = fullfile(opts.folder,'icons','folder.jpg');

            % image position
            uiimage(t,"ImageSource",IS,'Position',im_pos(y0))
        end

        % write task name
        uilabel(t,'Text',Tasks(task_ind).Name,'Position',lbl_pos(y0));
        y0 = y0 - opts.tx_h;
    end
end
end

function Activity = find_activity(Tasks,Date,SearchType)
%% Return struct containing TM recent activity info

% determine logical statement to use based on searchtype
switch lower(SearchType)
    case 'after'
        within_range = @(date) date > Date;
    case 'before'
        within_range = @(date) date < Date;
    case 'between'
        % work in either order
        Date = sort(Date);
        within_range = @(date) date > Date(1) & date < Date(2);
    otherwise
        error('elseif err')
end

% creations
ind                     = find(within_range([Tasks.CreationDate]));
Activity.created.ind    = ind;
Activity.created.dates  = [Tasks(ind).CreationDate];

% completions
completed_ind = find([Tasks.Completed]);
if isempty(completed_ind)
    Activity.completed.ind   = [];
    Activity.completed.dates = [];
else
    ind                      = completed_ind(within_range([Tasks(completed_ind).CompletionDate]));
    Activity.completed.ind   = ind;
    Activity.completed.dates = [Tasks(ind).CompletionDate];
end

% return all labels (for predicting panel height (add two for labels)
Activity.num_items = numel(Activity.completed.ind) + numel(Activity.created.ind) + 2;
end

function y0 = find_y0(num_items,panel_height,isCustom,opts)
%% Find starting vertical position for scrollable listing

% minimum y0 wanted (to keep objects at top of panel)
min_y0 = panel_height - opts.tx_h; 

if isCustom
    min_y0 = min_y0 - opts.btn_h;
end

% y0 from items (total height)
y0 = (num_items-1) * (opts.spacer + opts.tx_h);

% override with min value as necessary
if y0 < min_y0
    y0 = min_y0;
end
end