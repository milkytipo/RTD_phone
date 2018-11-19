function ldemo (action, option1);
% ----------------------------------------------------------------------
% File.....: ldemo.m
% Date.....: 19-MAY-1999
% Version..: 2.0b
% Author...: Peter Joosten (TUD/GEO)
%            Mathematical Geodesy and Positioning
%            Delft University of Technology
% Purpose..: Demonstration of the LAMBDA-method
% Language.: MATLAB 5.1
%
% Remarks..: This demonstration has some limitations, which do not apply
%            to the LAMBDA-routines itself:
%
%            - Maximum dimension of the problem = 6
%            - For readability, all numbers should fit in format "%8.4f"
%
% Arguments: None
% ----------------------------------------------------------------------

% ----------------------------------------------------------------------
% --- Initialize ---
% ----------------------------------------------------------------------

if nargin < 1; action = 'initialize'; end;

maxdim =  6;
curdim =  2;

% ----------------------------------------------------------------------
% Wait for actions ...
% ----------------------------------------------------------------------

switch action;

case 'initialize';

   % -----------------------------------------------
   % --- Initialize, which is the default action ---
   % -----------------------------------------------

   % -------------------------------------------
   % --- Define default options for controls ---
   % -------------------------------------------

   BackgroundColor = [0.0000 0.5966 1.0000];

   % ------------------------------
   % --- Create the main figure ---
   % ------------------------------
   
   ScreenSize = get(0,'ScreenSize');
   FigLeft    = (ScreenSize(3) - 640)  / 2;
   FigBottom  = (ScreenSize(4) - 480) / 2;
   
   h = figure (...
       'tag','LAMBDA', ...
       'name','LAMBDA-demonstration', ...
       'position',[FigLeft FigBottom 640 480]);

   % ----------------------
   % --- Action buttons ---
   % ----------------------

   h = uicontrol (...
       'Style','Frame', ...
       'Position',[552 236 86 242], ...
       'BackgroundColor',BackgroundColor);
       
   h = uicontrol (...
       'Style','Pushbutton', ...
       'Position',[555 443 80 32], ...
       'String','Compute !', ...
       'Callback','ldemo ''compute''');

   h = uicontrol (...
       'Style','Pushbutton', ...
       'Position',[555 408 80 32], ...
       'String','About', ...
       'Callback','ldemo ''about''');

   h = uicontrol (...
       'Style','Pushbutton', ...
       'Position',[555 373 80 32], ...
       'String','Exit', ...
       'Callback','ldemo ''exit''');
   
   % -------------------------
   % --- Input/Output file ---
   % -------------------------

   h = uicontrol (...
       'Style','Frame', ...
       'Position',[2 370 518 108], ...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
       'Style','Text', ...
       'Position',[5 447 120 20], ...
       'String','Inputfile:', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
      'Style','Edit', ...
      'Position',[130 450 300 20], ...
      'HorizontalAlignment','Left', ...
      'BackgroundColor',[1 1 1], ...
      'Tag','InputFile');

   h = uicontrol (...
       'Style','Pushbutton', ...
       'Position',[435 450 80 20], ...
       'String','Select', ...
       'Callback','ldemo SelectFile In');
   
   h = uicontrol (...
       'Style','Text', ...
       'Position',[5 427 120 20], ...
       'String','Outputfile:', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
      'Style','Edit', ...
      'Position',[130 430 300 20], ...
      'HorizontalAlignment','Left', ...
      'BackgroundColor',[1 1 1], ...
      'Tag','OutputFile');

   h = uicontrol (...
       'Style','Pushbutton', ...
       'Position',[435 430 80 20], ...
       'String','Select', ...
       'Callback','ldemo SelectFile Out');
   
   % ----------------------------
   % --- Number of candidates ---
   % ----------------------------
   
   h = uicontrol (...
       'Style','Text', ...
       'Position',[5 407 120 20], ...
       'String','Number of candidates:', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
      'Style','Edit', ...
      'Position',[130 410 50 20], ...
      'HorizontalAlignment','Left', ...
      'BackgroundColor',[1 1 1], ...
      'Tag','ncands', ...
      'String',2);

   % --------------------------------
   % --- Dimension of the problem ---
   % --------------------------------
   
   h = uicontrol (...
       'Style','Text', ...
       'Position',[5 387 120 20], ...
       'String','Dimension:', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
      'Style','Edit', ...
      'Position',[130 390 50 20], ...
      'HorizontalAlignment','Left', ...
      'BackgroundColor',[1 1 1], ...
      'Tag','dimension', ...
      'Callback','ldemo dimension', ...
      'String',num2str(curdim));

   % -------------------------------
   % --- Radiobuttons for output ---
   % -------------------------------
   
   h = uicontrol ( ...
       'Style','RadioButton', ...
       'Position',[200 410 200 18], ...
       'String','No intermediate output', ...
       'BackgroundColor',BackgroundColor, ...
       'Tag','IntOut0', ...
       'Value',1, ...
       'Callback','ldemo intout 0');

   h = uicontrol ( ...
       'Style','RadioButton', ...
       'Position',[200 392 200 18], ...
       'String','Intermediate output to screen', ...
       'BackgroundColor',BackgroundColor, ...
       'Tag','IntOut1', ...
       'Value',0, ...
       'Callback','ldemo intout 1');

   h = uicontrol ( ...
       'Style','RadioButton', ...
       'Position',[200 374 200 18], ...
       'String','Intermediate output to file', ...
       'BackgroundColor',BackgroundColor, ...
       'Tag','IntOut2', ...
       'Value',0, ...
       'Callback','ldemo intout 2');

   % -----------------------------------------
   % --- Create a box for Qahat and afloat ---
   % -----------------------------------------

   h = uicontrol (...
       'Style','Frame', ...
       'Position',[2 236 518 132], ...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
       'Style','Text', ...
       'Position',[7 343 80 20], ...
       'String','Float:', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   h = uicontrol (...
       'Style','Text', ...
       'Position',[92 343 200 20], ...
       'String','Variance/covariance matrix', ...
       'HorizontalAlignment','Left',...
       'BackgroundColor',BackgroundColor);

   for j = 1:maxdim;
      tag = ['float' sprintf('%2.2d',j)];
      ix  = 5;
      iy  = 328 - (j-1) * 18;
      h   = uicontrol ( ...
          'Style','Edit', ...
          'Position',[ix iy 80 18], ...
          'HorizontalAlignment','Left', ...
          'BackgroundColor',[1 1 1], ...
          'String','0.0000', ...
          'Tag',tag);

      if j <= curdim;
         set (h,'Enable','On');
      else;
         set (h,'Enable','Off');
      end;
      
   end;

   for i = 1:maxdim; for j = 1:maxdim;
      tag = ['mat' sprintf('%2.2d',i) sprintf('%2.2d',j)];
      ix  = 90  + (i-1) * 70;
      iy  = 328 - (j-1) * 18;
      h   = uicontrol ( ...
          'Style','Edit', ...
          'Position',[ix iy 70 18], ...
          'HorizontalAlignment','Left', ...
          'BackgroundColor',[1 1 1], ...
          'String','0.0000', ...
          'Callback',['ldemo makesymm ' tag], ...
          'Tag',tag);

      if j <= curdim & i <= curdim;
         set (h,'Enable','On');
      else;
         set (h,'Enable','Off');
      end;

   end; end;

   % -------------------------------------------
   % --- Box for elongation of the ellipsoid ---
   % -------------------------------------------

   % ------------------------------
   % --- Box for compution time ---
   % ------------------------------
   
   % ------------------------------------------
   % --- Box for output of results integers ---
   % ------------------------------------------

   h = uicontrol (...
       'Style','Text', ...
       'Position',[5 124 300 16], ...
       'String','Estimated fixed ambiguities:', ...
       'HorizontalAlignment','Left', ...
       'BackgroundColor', [0.8 0.8 0.8]);
   
   h = uicontrol ( ...
       'Style','Edit', ...
       'Position',[2 2 636 120], ...
       'BackgroundColor',[1 1 1], ...
       'HorizontalAlignment','left', ...
       'FontName','Courier New', ...
       'Max',10, ...
       'Tag','results');

case 'intout';

   switch option1;
   case '0';
      set (findobj (gcf,'Tag','IntOut0'),'Value',1);
      set (findobj (gcf,'Tag','IntOut1'),'Value',0);
      set (findobj (gcf,'Tag','IntOut2'),'Value',0);
   case '1';
      set (findobj (gcf,'Tag','IntOut0'),'Value',0);
      set (findobj (gcf,'Tag','IntOut1'),'Value',1);
      set (findobj (gcf,'Tag','IntOut2'),'Value',0);
   case '2';
      set (findobj (gcf,'Tag','IntOut0'),'Value',0);
      set (findobj (gcf,'Tag','IntOut1'),'Value',0);
      set (findobj (gcf,'Tag','IntOut2'),'Value',1);
   end;   

case 'SelectFile';

   switch option1;
      
   case 'In';
      
      [FileName,PathName] = uigetfile ('*.mat','Select file');
      load ([PathName FileName]);
      Qahat  = Q; clear Q;
      afloat = a; clear a;
      curdim = size(Qahat,1);
      %[FileName,PathName]   = uigetfile ('*.amb','Select file');
      %      [Qahat,afloat,curdim,ierr] = ReadCovar ([PathName FileName]);
      
      h = findobj (gcf,'Tag','InputFile');
      set (h,'String',FileName);

      h = findobj(gcf,'Tag','dimension');
      set (h,'String',num2str(curdim));

      for i = 1:maxdim;
         tag = ['float' sprintf('%2.2d',i)];
         h   = findobj(gcf,'Tag',tag);
         if i <= curdim;
            set (h,'Enable','On');
            set (h,'String',sprintf ('%8.4f',afloat(i)));
         else;
            set (h,'Enable','Off');
            set (h,'String','0.0000');
         end;
      end;

      for i = 1:maxdim; for j = 1:maxdim
         tag = ['mat' sprintf('%2.2d',i) sprintf('%2.2d',j)];
         h   = findobj(gcf,'Tag',tag);
         if i <= curdim & j <= curdim;
            set (h,'Enable','On');
            set (h,'String',sprintf ('%8.4f',Qahat(i,j)));
         else;
            set (h,'Enable','Off');
            set (h,'String','0.0000');
         end;
      end; end;

   case 'Out';
      
      [FileName,PathName]   = uiputfile ('*.log','Select file');
      h = findobj (gcf,'Tag','OutputFile');
      set (h,'String',FileName);

      set (findobj (gcf,'Tag','IntOut0'),'Value',0);
      set (findobj (gcf,'Tag','IntOut1'),'Value',0);
      set (findobj (gcf,'Tag','IntOut2'),'Value',1);

   end;

case 'dimension';

   % -------------------------------------------
   % --- Change the dimension of the problem ---
   % -------------------------------------------
   
   h = findobj(gcf,'Tag','dimension');
   curdim = str2num (get (h,'String'));

   if curdim < 1 | curdim > maxdim;
      msgbox ('Please select a dimension between 1 and 12','Illegal dimension','error');
   end;

   for i = 1:maxdim;
      tag = ['float' sprintf('%2.2d',i)];
      h   = findobj(gcf,'Tag',tag);
      if i <= curdim;
         set (h,'Enable','On');
      else;
         set (h,'Enable','Off');
      end;
   end;

   for i = 1:maxdim; for j = 1:maxdim
      tag = ['mat' sprintf('%2.2d',i) sprintf('%2.2d',j)];
      h   = findobj(gcf,'Tag',tag);
      if i <= curdim & j <= curdim;
         set (h,'Enable','On');
      else;
         set (h,'Enable','Off');
      end;
   end; end;

case 'makesymm'

   i   = str2num (option1(4:5));
   j   = str2num (option1(6:7));
   h   = findobj(gcf,'Tag',option1);
   tmp = get (h,'String');
   tag = ['mat' sprintf('%2.2d',j) sprintf('%2.2d',i)];
   h   = findobj(gcf,'Tag',tag);
   set (h,'String',tmp);   

case 'compute'

   % ------------------------------------
   % --- Collect the input for LAMBDA ---
   % ------------------------------------

   watchon;
   h      = findobj(gcf,'Tag','ncands');
   ncands = str2num(get(h,'String'));

   h = findobj(gcf,'Tag','dimension');
   curdim = str2num (get (h,'String'));

   afloat = zeros(curdim,1);
   Qahat  = zeros(curdim,curdim);

   for j = 1:curdim;
      tag       = ['float' sprintf('%2.2d',j)];
      h         = findobj (gcf,'Tag',tag);
      afloat(j) = str2num(get(h,'String'));
   end;
   
   for i = 1:curdim; for j = 1:curdim;
      tag        = ['mat' sprintf('%2.2d',i) sprintf('%2.2d',j)];
      h          = findobj (gcf,'Tag',tag);
      Qahat(i,j) = str2num(get(h,'String'));
   end; end;

   if get (findobj (gcf,'Tag','IntOut0'),'Value'); FidLog = 0; end;
   if get (findobj (gcf,'Tag','IntOut1'),'Value'); FidLog = 1; end;
   if get (findobj (gcf,'Tag','IntOut2'),'Value');
      FileName = get (findobj (gcf,'Tag','OutputFile'),'String');
      FidLog = fopen (FileName,'wt');
   end;

   % ------------------------------------------
   % --- Perform checks on validity of data ---
   % ------------------------------------------

   % -------------------------------------
   % --- Estimate integer using LAMBDA ---
   % -------------------------------------
   
   [afixed,sqnorm,Qahat,Z] = lambda1 (afloat,Qahat,ncands,FidLog);
   if FidLog > 1; fclose (FidLog); end;
   
   % ---------------------------------------------
   % --- Write the results to the output-field ---
   % ---------------------------------------------
   
   string = char(ones(curdim+2,ncands*13+10)*32);
   string(1,1:8) = 'fixed  :';
   string(curdim+2,1:8) = 'sq.norm:';

   for i = 1:curdim; for j = 1:ncands;
      istart = 10 + (j-1)*13;
      string(i,istart:istart+10) = sprintf ('%11.4f',afixed(i,j));
   end; end;
   
   for i = 1:ncands;
      istart = 10 + (i-1)*13;
      string(curdim+2,istart:istart+10) = sprintf ('%11.4f',sqnorm(i));
   end;

   h = findobj (gcf,'Tag','results');
   set (h,'String',string);
   watchoff;

case 'about';

	% -------------
	% --- About ---
	% -------------

   helpwin (mfilename);

case 'exit';

	% ------------
	% --- Exit ---
	% ------------

   close (gcbf);
   disp ('Bye ...');

otherwise;
   
   disp (['Warning ldemo: Illegal option choosen, please try again ...']);
   disp (['               Option: ' action]);

end;

% ----------------------------------------------------------------------
% --- End of the main routine, start of internal functions ---
% ----------------------------------------------------------------------

function [Qahat,afloat,n,ierr] = ReadCovar (FileName)
% ----------------------------------------------------------------------
% Internal function: ReadCovar
% Author...........:
% Date.............:
% Purpose..........:
% Remarks..........:
% ----------------------------------------------------------------------

ierr      = 0;
[Fid,Msg] = fopen (FileName,'r');

if Fid == -1; 

   error (Msg);

else;

   [n,count]   = max(fscanf (Fid,'%d',1));
   if count ~= 1; error ('Error ReadCovar: Error reading dimension (n) ==> Check inputfile ...'); end;
   
   [Qahat,count] = fscanf (Fid,'%f',n*n);
   if count ~= n*n; error ('Error ReadCovar: Error reading var/covar matrix (n) ==> Check inputfile ...'); end;
   
   [afloat,count] = fscanf (Fid,'%f',n);
   if count ~= n; error ('Error ReadCovar: Error reading float-vector (n) ==> Check inputfile ...'); end;

   Qahat = reshape (Qahat,n,n);

   fclose (Fid);
   
end;

