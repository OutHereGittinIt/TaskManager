function UserData = update_task_manager_compatibility(UserData,opts)
%
% Fix old Task Manager UserDatafiles to work with latest script revision
% 
% David Richardson 
% 07/21/2024

% description font weight - flag vs. bold/normal
% if islogical(UserData.DescFontWeight)
%     if UserData.DescFontWeight
%         UserData.DescFontWeight = 'bold';
%     else
%         UserData.DescFontWeight = 'normal';
%     end
% end
% 
% % task  vs. taskheight fieldname
% if isfield(UserData.Tasks,'TaskHeight')
%     for ind = 1:numel(UserData.Tasks)
%         UserData.Tasks(ind).Height = UserData.Tasks(ind).TaskHeight;
%     end
%     UserData.Tasks = rmfield(UserData.Tasks,'TaskHeight');
% end
% 
% % Add numtasks
% if ~isfield(UserData,'NumTasks')
%     UserData.Numtasks = find(cellfun('isempty',{UserData.Tasks.Name}),1) - 1;
% end
% 
% % optional show fields seperated by '.'
% showfields = {'CompletionDate','CreationDate','Regularity'}; % could be 2 more, but not yet. doubtful in future
% 
% % change example task to original (to read task position)
% if ~UserData.Tasks(opts.max_num_tasks).isOriginal
%     UserData.Tasks(opts.max_num_tasks).isOriginal = true;
% end
% 
% % change example task priority to real number (to sort task ind)
% if isempty(UserData.Tasks(opts.max_num_tasks).Priority)
%     UserData.Tasks(opts.max_num_tasks).Priority = opts.max_num_tasks;
% end

if ~isfield(UserData,'folder_clr')
    UserData.folder_clr = opts.DefaultSettings.folder_clr;
end

if ~isfield(UserData.Tasks,'isFolder')
    for ind = 1:UserData.NumTasks
        UserData.Tasks(ind).isFolder = false;
    end
end

if ~isfield(UserData.Tasks,'Collapsed')
    for ind = 1:UserData.NumTasks
        UserData.Tasks(ind).Collapsed = false;
    end
end

if ~isfield(UserData.Tasks,'Collapsing')
    for ind = 1:UserData.NumTasks
        UserData.Tasks(ind).Collapsing = false;
    end
end

if ~isfield(UserData.Tasks,'Width')
    for ind = 1:UserData.NumTasks
        UserData.Tasks(ind).Width = [];
    end
end

% dt = datetime;
% for ind = 1:UserData.NumTasks
%     if UserData.Tasks(ind).Completed && isempty(UserData.Tasks(ind).CompletionDate)
%         UserData.Tasks(ind).CompletionDate = dt;
%     end
% end
% 
% if isempty(UserData.Tasks(opts.max_num_tasks).isFolder)
%     UserData.Tasks(opts.max_num_tasks).isFolder = false;
% end


if ~isfield(UserData,'deleted_clr')
    UserData.deleted_clr = opts.DefaultSettings.deleted_clr;
end

if ~isfield(UserData,'DefaultDueDate')
    UserData.DefaultDueDate = 'N/A';
end

if ~isfield(UserData,'AutoSetPriority')
    UserData.AutoSetPriority = false;
end

if ~isfield(UserData,'UnsavedChangesPresent')
    UserData.UnsavedChangesPresent = false;
end

% Mark when this UserData file has been updated
UserData.CompatabilityVerified = '5/27/2025';
end