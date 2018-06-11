function [answer rt] = waitForKB_linux(targetkey,visual_onset,maxtime)

%leftarrow = KbName('LeftArrow');
%rightarrow = KbName('RightArrow');

while KbCheck; end % Wait until all keys are released.

if nargin < 2
    startSecs = GetSecs;
else
    startSecs=visual_onset;
end
if nargin < 3
    maxtime = +Inf;
end
answer=-1;

while 1
    % Check the state of the keyboard.
    if GetSecs-startSecs>maxtime
        answer = 0;
        rt     = maxtime;
        break
    end
	[ keyIsDown, seconds, keyCode ] = KbCheck;
   
    % If the user is pressing a key, then display its code number and name.
    % 114 left 115 right
    if keyIsDown

        % Note that we use find(keyCode) because keyCode is an array.
        % See 'help KbCheck'
        %fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));

        if any(keyCode(KbName(targetkey)))
            rt = seconds - startSecs;
            answer=find(keyCode(KbName(targetkey)));
            break;
        end
        
        % If the user holds down a key, KbCheck will report multiple events.
        % To condense multiple 'keyDown' events into a single event, we wait until all
        % keys have been released.
        while KbCheck; end
    end
end
end
