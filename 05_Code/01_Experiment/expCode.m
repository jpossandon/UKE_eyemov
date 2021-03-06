% PsychDebugWindowConfiguration(0,.5);                                      % to debug with one screen
%%
% EXPERIMENT PARAMETERS
exppath                     = '/Users/jossando/trabajo/UKE_eye/';
% screen parameters
win.whichScreen             = 2;                                            % (CHANGE?) here we define the screen to use for the experiment, it depend on which computer we are using and how the screens are conected so it might need to be changed if the experiment starts in the wrong screen
win.FontSZ                  = 20;                                           % (CHANGE?) font size
win.bkgcolor                = [0 0 0];                                      % screen background color, [0 0 0] black
win.Vdst                    = 30;                                           % (!CHANGE!) viewer's distance from screen [cm]         
win.res                     = [2048 1536];                                  % (!CHANGE!) horizontal x vertical resolution [pixels]
win.wdth                    = 21.35;                                           % (!CHANGE!) screen size in cms
win.hght                    = 16.1;                                         % 
win.pixxdeg                 = win.res(1)/(2*180/pi*atan(win.wdth/2/win.Vdst));% 
win.start_time              = clock; 

% subject 
win.s_n                     = input('Subject number: ','s');                % subject id number
logpath = fullfile(exppath,'06_RawData',[datestr(now,'yymmdd') '_' win.s_n]);
mkdir(logpath)

% experiment elements size, color, etc
win.dotsiz                  = 100;             % pixels
win.dotcol                  = [255 255 255;
                               255   0   0;
                                 0   0 255];  % 1st row - color dot RF mapping, 2nd,3rd row colors task
colnames                    = {'white','red','blue'};                             
win.dotdur                  = 4;              % duration in seconds of dot appearance for RF mappin
win.fixSize                 = 50;             % length in pixels of fix cross arm
win.fixcrosswidth           = 10;             % fixation cross line width
% experiement trial timing
win.lat_cue_targetON        = 2;              % time between cue color change and apearrance of target  
win.lat_targetON            = 2;              % duration of the target on the screen
win.lat_targetsOFF_GO       = 2;              %time between targets disapearrance and go signal  
win.movmaxlat               = 2;              % time to move from go signal

% PTB parameters
AssertOpenGL();                                                             % check if Psychtoolbox is working (with OpenGL) TODO: is this needed?
ClockRandSeed();                                                            % this changes the random seed
prevVerbos = Screen('Preference','Verbosity', 2);                           % this two lines it to set how much we want the PTB to output in the command and display window 
prevVisDbg = Screen('Preference','VisualDebugLevel',3);                     % verbosity-1 (default 3); vdbg-2 (default 4)
Screen('Preference', 'SkipSyncTests', 2)                                    % (!CHANGE!) this need to be changed to the set with better reliabiltiy for the setup
% Screen('Preference', 'SkipSyncTests', 0)                                    % for maximum accuracy and reliability

%%
% open a PTB window
[win.hndl, win.rect]        = Screen('OpenWindow',win.whichScreen,win.bkgcolor);   % starts PTB screen

[win.cntr(1), win.cntr(2)] = WindowCenter(win.hndl);                        % get where is the display screen center
Screen('BlendFunction',win.hndl, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);     % enable alpha blending for smooth drawing
% HideCursor(win.hndl);                                                       % this to hide the mouse
Screen('TextSize', win.hndl, win.FontSZ);                                  % sets teh font size of the text to be diplayed
KbName('UnifyKeyNames'); 

save(fullfile(logpath,[datestr(now,'HHMMSS'),'_subj_' win.s_n '_params']),'win')
% rect for fixation cross in the middle
fixrect = round([win.cntr(1)-win.fixSize win.cntr(1)+win.fixSize win.cntr(1) win.cntr(1);...
                    win.cntr(2) win.cntr(2) win.cntr(2)-win.fixSize win.cntr(2)+win.fixSize]);

% TASKS

todonow = 0;                                        % flag for task selector
textLoc = {'RF','no-RF'};
while isempty(todonow) || todonow~=9 
    
    % what do we do next?
    todonow = str2num(input(sprintf('\n\nNext procedure: \n1 - RFmap manual\n2 - RFmap automatic\n3 - RFmap automatic move\n4 - Delayed cued movement\n9 - Stop experiment\n>'),'s')) ;
    % 
    %%%%%%%%%%%%
    % 1 - RF map manual
    %%%%%%%%%%%
    if todonow==1
        neuronID   = input(sprintf('\nneuronID: '),'s');
        sttime     = datestr(now,'HHMMSS');
        logTask = cell2table(cell(0,5),'VariableNames',{'PCtime','mapRFtype','xpos','ypos','neuronID'});
        sprintf('\n##################\nMAPPING RF MANUAL\n##################\n')
         Screen('FillRect', win.hndl, win.bkgcolor);
         Screen('DrawLines', win.hndl,fixrect,...
                2,[255 255 255],[0 0]);
         Screen('Flip', win.hndl);
            
        mapFig = figure;
        mapFig.Position = [2400 500 win.rect(3:4)/3];                       % (!CHANGE!) put the figure in the experimental computer screen and adjust size to the size of the display screen
        axis([0 win.rect(3) 0 win.rect(4)])                                 % make axes the same size as display screen
        axhandle            = gca;
        axhandle.Position   = [0.025 0.025 .975 .975];                            % remove figure borders and set color to same color as screen
        vline(win.cntr(1)); hline(win.cntr(2));                             % guides for screen center
        patch([0 win.rect(3)*.025 win.rect(3)*.025 0]',[0 0 win.rect(3)*.025 win.rect(3)*.025]',[1 0 0])
        text(win.rect(3)*.027,win.rect(3)*.015,'Stop','Color',[1 0 0])
        axis ij
        
        while 1
            [x,y] = ginput(1);
            Screen('DrawLines', win.hndl,fixrect,...
                2,[255 255 255],[0 0]);
            Screen('DrawDots',win.hndl,round([x;y]),win.dotsiz,win.dotcol(1,:),[0 0],2);
            Screen('FillRect',win.hndl,[255 255 255],[0 0 50 50])          % this is for diode
            fliptime = Screen('Flip', win.hndl);
            % here trigger
            Screen('FillRect', win.hndl, win.bkgcolor);
            Screen('DrawLines', win.hndl,fixrect,...
                2,[255 255 255],[0 0]);
            fprintf('\n X:%04d  Y:%04d',round(x),round(y))
            while 1, if GetSecs-fliptime>win.dotdur,break,end,end          % presentation time
            Screen('Flip', win.hndl);
            logTask = [logTask;{datestr(now,'yymmddHHMMSSFFF'),todonow,round(x),round(y),neuronID}];
            save(fullfile(logpath,[sttime '_manualRF_' neuronID]),'logTask')
            if x<win.rect(3)*.025 & y<win.rect(4)*.025
                logTask
                fprintf('\n logTask saved on %s\n',fullfile(logpath,[sttime '_manualRF' neuronID]))
                break
            end
        end
        close(mapFig)
        
    end
    
    % automatic RF map
    if todonow==2
        neuronID   = input(sprintf('\nneuronID: '),'s');
        sttime     = datestr(now,'HHMMSS');
        logTask = cell2table(cell(0,5),'VariableNames',{'PCtime','mapRFtype','xpos','ypos','neuronID'});
        
        sprintf('\n##################\nMAPPING RF AUTOMATIC\n##################\n')
        pos     = str2num(input(sprintf('\n\nHow many positions to map (use a power of 2):'),'s'));
        reps    = str2num(input(sprintf('\nHow many repetitions:'),'s'));
        jitt    = str2num(input(sprintf('\nJitter (pixels):'),'s'));
        pos     = ceil(sqrt(pos))^2;  % find the next square number
        xpos    = round(linspace(win.rect(1)+win.rect(3)/(sqrt(pos)+1),win.rect(3)-win.rect(3)/(sqrt(pos)+1),sqrt(pos)));
        ypos    = round(linspace(win.rect(2)+win.rect(4)/(sqrt(pos)+1),win.rect(4)-win.rect(4)/(sqrt(pos)+1),sqrt(pos)));
        poslocs = repmat(combvec(xpos,ypos)',reps,1);
        poslocs = poslocs+jitt*reshape(randsample([-1 1],pos*2*reps,'true'),size(poslocs));
        poslocs = poslocs(randsample(size(poslocs,1),size(poslocs,1)),:);
        Screen('FillRect', win.hndl, win.bkgcolor);
        Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
        Screen('Flip', win.hndl);
            
         for nn = 1:size(poslocs,1)
            [x,y]=deal(poslocs(nn,1),poslocs(nn,2));
            Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
            Screen('DrawDots',win.hndl,round([x;y]),win.dotsiz,win.dotcol(1,:),[0 0],2);
            fliptime = Screen('Flip', win.hndl);
            % here trigger
            Screen('FillRect', win.hndl, win.bkgcolor);
            Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
            fprintf('\n X:%04d  Y:%04d',round(x),round(y))
            doescape = waitForKB_linux({'escape'},fliptime,win.dotdur);
            if doescape==1
                break 
            end
%             WaitSecs(win.dotdur);
            Screen('Flip', win.hndl);
            logTask = [logTask;{datestr(now,'yymmddHHMMSSFFF'),todonow,round(x),round(y),neuronID}];
            save(fullfile(logpath,[sttime '_autoRF_' neuronID]),'logTask')
            % TODO: make escape possible
         end
        logTask
        fprintf('\n logTask saved on %s\n',fullfile(logpath,[sttime '_autoRF_' neuronID]))
    end
    
    if todonow==3
        neuronID   = input(sprintf('\nneuronID: '),'s');
        sttime     = datestr(now,'HHMMSS');
        logTask = cell2table(cell(0,5),'VariableNames',{'PCtime','mapRFtype','xpos','ypos','neuronID'});
        
        sprintf('\n##################\nMAPPING RF AUTOMATIC\n##################\n')
        pos     = str2num(input(sprintf('\n\nHow many positions to map (use a power of 2):'),'s'));
        reps    = str2num(input(sprintf('\nHow many repetitions:'),'s'));
        jitt    = str2num(input(sprintf('\nJitter (pixels):'),'s'));
        pos     = ceil(sqrt(pos))^2;  % find the next square number
        xpos    = round(linspace(win.rect(1)+win.rect(3)/(sqrt(pos)+1),win.rect(3)-win.rect(3)/(sqrt(pos)+1),sqrt(pos)));
        ypos    = round(linspace(win.rect(2)+win.rect(4)/(sqrt(pos)+1),win.rect(4)-win.rect(4)/(sqrt(pos)+1),sqrt(pos)));
        poslocs = repmat(combvec(xpos,ypos)',reps,1);
        poslocs = poslocs+jitt*reshape(randsample([-1 1],pos*2*reps,'true'),size(poslocs));
        poslocs = poslocs(randsample(size(poslocs,1),size(poslocs,1)),:);
        Screen('FillRect', win.hndl, win.bkgcolor);
        Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
        Screen('Flip', win.hndl);
            
         for nn = 1:size(poslocs,1)
            [x,y]=deal(poslocs(nn,1),poslocs(nn,2));
            fprintf('\n Press SPACE key to next point, ESC to stop',tt,textLoc{trialtarget(tt)})
            doescape = waitForKB_linux({'space','escape'});
            if doescape==2
                break 
            end
            Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
            Screen('DrawDots',win.hndl,round([x;y]),win.dotsiz,win.dotcol(1,:),[0 0],2);
            fliptime = Screen('Flip', win.hndl);
            % here trigger
            Screen('FillRect', win.hndl, win.bkgcolor);
            Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
            fprintf('\n X:%04d  Y:%04d',round(x),round(y))
            doescape = waitForKB_linux({'escape'},fliptime,win.dotdur);
            if doescape==1
                break 
            end
%             WaitSecs(win.dotdur);
            
            Screen('Flip', win.hndl);
            logTask = [logTask;{datestr(now,'yymmddHHMMSSFFF'),todonow,round(x),round(y),neuronID}];
            save(fullfile(logpath,[sttime '_autoRF_' neuronID]),'logTask')
            % TODO: make escape possible
         end
        logTask
        fprintf('\n logTask saved on %s\n',fullfile(logpath,[sttime '_autoRFmove_' neuronID]))
    end
    
    % Task
    if todonow==4
        neuronID   = input(sprintf('\nneuronID: '),'s');
        sttime     = datestr(now,'HHMMSS');
        logTask = cell2table(cell(0,8),'VariableNames',{'PCtime','movetoRF','colorTarget','RFxpos','RFypos','noRFxpos','noRFypos','neuronID'});
        sprintf('\n##################\nDelayed saccade to cued position\n##################\n');
        nTrials   = str2num(input(sprintf('\n# of trials (even number): '),'s'));
        posRF     = str2num(input(sprintf('\nPosition target mapped RF location (x,y): '),'s'));
        posnoRFc  = str2num(input(sprintf('\nPosition target non-mapped location (eg, (-1,1) = opposite horizontal, same vertical): '),'s'));
        posnoRF   = win.cntr-(win.cntr-posRF).*posnoRFc;
        posel     = [posRF',posnoRF'];
        fprintf('\n     RF Position:%d,%d',posRF(1),posRF(2))
        fprintf('\n Non-RF Position:%d,%d\n',posnoRF(1),posnoRF(2))
        
        % randomization
        trialtarget = randsample(repmat([1,2],1,nTrials/2),nTrials);       % 1 - movement to RF location, 2 - movement to non-RF location
        
        for tt = 1:nTrials
           % white fix cross
           Screen('FillRect', win.hndl, win.bkgcolor);
           Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,[255 255 255],[0 0]);
           Screen('Flip', win.hndl);
           
           % experiemnter starts trials - cue alone (change of fixation cross to color of the target location)
           colRand = randsample([2 3],2);                                   % decide which of win.dotcol wil be the color of the target and which one the non-target
           fprintf('\n Press SPACE key to start trial %d  (movement to %s location), ESC to stop',tt,textLoc{trialtarget(tt)})
           doescape = waitForKB_linux({'space','escape'});
           if doescape==2
              break 
           end
           Screen('FillRect', win.hndl, win.bkgcolor);
           Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,win.dotcol(colRand(1),:),[0 0]);
           fliptime = Screen('Flip', win.hndl);
           % HERE TRIGGER CUE ALONE
           
           % cue, target and distrator
           Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,win.dotcol(colRand(1),:),[0 0]);
           if trialtarget(tt)==1 % movement to RF
                Screen('DrawDots',win.hndl,posel,win.dotsiz,win.dotcol(colRand,:)',[0 0],2);
           else
                Screen('DrawDots',win.hndl,fliplr(posel),win.dotsiz,win.dotcol(colRand,:)',[0 0],2);
           end
           while 1, if GetSecs-fliptime>win.lat_cue_targetON,break,end,end 
           fliptime = Screen('Flip', win.hndl);
           % HERE TRIGGER ON TARGET
           
            % again cue alone
           Screen('DrawLines', win.hndl,fixrect,...
                win.fixcrosswidth,win.dotcol(colRand(1),:),[0 0]);
           while 1, if GetSecs-fliptime>win.lat_targetON,break,end,end 
           fliptime = Screen('Flip', win.hndl);
           % HERE TRIGGER OFF TARGET
           
           % Off cue - go signal
           Screen('FillRect', win.hndl, win.bkgcolor);
           while 1, if GetSecs-fliptime>win.lat_targetsOFF_GO,break,end,end 
           fliptime = Screen('Flip', win.hndl);
           % HERE TRIGGER OFF CUE
           
           % wait for movement ()
           while 1, if GetSecs-fliptime>win.movmaxlat,break,end,end 
           logTask = [logTask;{datestr(now,'yymmddHHMMSSFFF'),trialtarget(tt),colnames{2},posRF(1),posRF(2),posnoRF(1),posnoRF(2),neuronID}];
           save(fullfile(logpath,[sttime '_delayedCueTask_' neuronID]),'logTask')
        end
        logTask
        fprintf('\n logTask saved on %s\n',fullfile(logpath,[sttime '_delayedCueTask_' neuronID]))
    end
end

Screen('CloseAll');                                                         % close the PTB screen
Screen('Preference','Verbosity', prevVerbos);                               % restore previous verbosity
Screen('Preference','VisualDebugLevel', prevVisDbg);                        % restore prev vis dbg
ListenChar(1)                                                               % restore MATLAB keyboard listening (on command window)
