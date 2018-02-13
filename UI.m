function octaveUI()
  
  close all
  clear
  
  global workFolder;
  workFolder=pwd;
  
  global isMatlab;

  try
    eval('graphics_toolkit qt;');
  catch error
    isMatlab=true;
  end
  

  f = createMainFigure();

  handles = createStaticUI(f);

  % get config file values
  numberOfSimulations = getFromConfigOrDefault('NB_SIMULATIONS',1);
  numberOfSteps = getFromConfigOrDefault('NB_STEPS',20);
  initialNumberOfCells = getFromConfigOrDefault('INIT_NB_CELLS',28500);
  percentageMesenchymalCells = getFromConfigOrDefault('PERCENTAGE_MESENCHYMAL', []);
  snapshotSteps = getFromConfigOrDefault('SNAPSHOT_STEPS', []);
  dishSize = getFromConfigOrDefault('DISH_SIZE',300);
  dishHeight = getFromConfigOrDefault('DISH_HEIGHT',4);
  minSurvival = getFromConfigOrDefault('MIN_SURVIVAL',2);
  maxSurvival = getFromConfigOrDefault('MAX_SURVIVAL',3);
  birth = getFromConfigOrDefault('BIRTH',3);
  enable3DSnapshots = strcmp(getFromConfigOrDefault('SAVE_3D_SNAPSHOTS', 'OFF'), 'ON');
  enableSnapshots = strcmp(getFromConfigOrDefault('SAVE_SNAPSHOTS', 'OFF'), 'ON');


  handles2 = createRulesUI(handles, birth, minSurvival,maxSurvival);
  handles3 = createGraphicParamsUI(handles2, enableSnapshots, enable3DSnapshots, snapshotSteps);
  handles4 = createSimulationParamsUI(handles3, numberOfSimulations, numberOfSteps, initialNumberOfCells, percentageMesenchymalCells);
  handles5 = createDishParamsUI(handles4, dishSize, dishHeight);

  guidata (f, handles5)

end


% ----------------------- UI GENERATION ---------------------------

function f = createMainFigure()
  screensize = get(0, 'screensize');

  height = 500;
  width = 1200;

  f = figure('position', [(screensize(3)-width)/2 (screensize(4)-height)/2 width height], 'color', get(0, 'defaultuicontrolbackgroundcolor'), 'toolbar', 'none', 'menubar', 'none', 'name', 'Cancer AutoMata', 'numbertitle', 'off');
end

function handles = createStaticUI(f) 
  
  handles.panel = uipanel('parent',f, 'title', 'Simulation Properties', 'position', [0.01 0.01 0.58 0.98]);

  handles.rulePanel = uipanel('parent', handles.panel, 'title', 'Rules', 'position', [0.01 0.50 0.98 0.49]);

  handles.graphicPanel = uipanel('parent', handles.panel, 'title', 'Graphic Parameters', 'position', [0.01 0.01 0.32 0.48]);

  handles.simulationPanel = uipanel('parent', handles.panel, 'title', 'Simulation Parameters', 'position', [0.34 0.01 0.32 0.48]);

  handles.dishPanel = uipanel('parent', handles.panel, 'title', 'Dish Parameters', 'position', [0.67 0.21 0.32 0.28]);

  handles.runButton = uicontrol('parent', handles.panel, 'style', 'pushbutton', 'units', 'normalized', 'string', 'Run simulations', 'callback', @runSimulationButton_Callback, 'position', [0.67 0.01 0.32 0.20]);

  handles.curvesPlot = axes('parent', f, 'position', [0.60 0.21 0.39 0.77]);

  handles.progressText = uicontrol('parent', f, 'style', 'text', 'units', 'normalized', 'position', [0.60 0.01 0.39 0.16], 'string', '', 'fontunits', 'normalized', 'fontsize',0.15, 'horizontalalignment', 'center');

end

function handles = createRulesUI(handles, birth, minSurvival,maxSurvival)
  
  lineSize = 0.10;
  
  % ----- first rule ----------------------
  minSurvLineY = 0.85;
  handles.minSurvPart1 = uicontrol('parent',handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 minSurvLineY 0.18 lineSize], 'string', 'i)   Any E cell with < ', 'fontsize',10, 'horizontalalignment', 'left');
  handles.minimumSurvival = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.20 minSurvLineY 0.09 lineSize], 'string', minSurvival, 'fontsize',10, 'horizontalalignment', 'center', 'callback', @minimumSurvival_Callback);
  handles.minSurvPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 minSurvLineY 0.5 lineSize], 'string', 'live neighbors dies, caused by under-population.', 'fontsize',10, 'horizontalalignment', 'left');
  
  % ----- second rule ----------------------
  survivalLineY = 0.70;
  handles.survivalPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 survivalLineY 0.18 lineSize], 'string', 'ii)  Any E cell with ', 'fontsize',10, 'horizontalalignment', 'left');
  handles.survival = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.20 survivalLineY 0.09 lineSize], 'string', char(strcat(num2str(minSurvival), {' to '}, num2str(maxSurvival))), 'fontsize',10, 'horizontalalignment', 'center');
  handles.survivalPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 survivalLineY 0.5 lineSize], 'string', 'live neighbors lives on to the next generation.', 'fontsize',10, 'horizontalalignment', 'left');
  
  
  % ----- third rule ----------------------
  maxSurvLineY = 0.55;
  handles.minSurvPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 maxSurvLineY 0.18 lineSize], 'string', 'iii)  Any E cell with > ', 'fontsize',10, 'horizontalalignment', 'left');
  handles.maximumSurvival = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.20 maxSurvLineY 0.09 lineSize], 'string', maxSurvival, 'fontsize',10, 'horizontalalignment', 'center', 'callback', @maximumSurvival_Callback);
  handles.minSurvPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 maxSurvLineY 0.5 lineSize], 'string', 'live neighbors dies, caused by overcrowding.', 'fontsize',10, 'horizontalalignment', 'left');
  
  
  % ----- fourth rule ----------------------
  birthLineY = 0.40;
  handles.birthPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 birthLineY 0.27 lineSize], 'string', 'iv)   Any dead/empty cell with', 'fontsize',10, 'horizontalalignment', 'left');
  handles.birth = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.28 birthLineY 0.09 lineSize], 'string', num2str(birth), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @birth_Callback);
  handles.birthPart5 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.38 birthLineY 0.55 lineSize], 'string', 'live neighbors (E or M) becomes live E cell as by reproduction.', 'fontsize',10, 'horizontalalignment', 'left');
  
  % ----- fifth and sixth rule ----------------------

  handles.rule5 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 0.25 0.98 lineSize], 'string', 'v) Any M cell is able to move randomly to an empty cell on to the next generation.', 'fontsize',10, 'horizontalalignment', 'left');
  handles.rule6 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 0.10 0.98 lineSize], 'string', 'vi)   Any M cell that is unable to move becomes an E cell on to the next generation.', 'fontsize',10, 'horizontalalignment', 'left');
  
end
function handles = createGraphicParamsUI(handles, enableSnapshots, enable3DSnapshots, snapshotSteps)

  handles.dishSnapshots = uicontrol ('parent', handles.graphicPanel, 'style', 'checkbox', 'units', 'normalized', 'position', [0.03 0.75 0.96 0.15], 'string', 'Save 2D dish snapshots', 'fontsize',10, 'value', enableSnapshots, 'horizontalalignment', 'left');
  
  handles.dish3DSnapshots = uicontrol ('parent', handles.graphicPanel, 'style', 'checkbox', 'units', 'normalized', 'position', [0.03 0.55 0.96 0.15], 'string', 'Save 3D dish snapshots.', 'fontsize',10, 'value', enable3DSnapshots, 'horizontalalignment', 'left');
  
  lineY = 0.35;
  handles.snapshotStepsText = uicontrol ('parent', handles.graphicPanel, 'style', 'text', 'units', 'normalized', 'position', [0.03 lineY 0.42 0.15], 'string', 'Snapshot steps:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.snapshotSteps = uicontrol ('parent', handles.graphicPanel, 'style', 'edit', 'units', 'normalized', 'position', [0.48 lineY 0.50 0.15], 'string', num2str(snapshotSteps), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @snapshotSteps_Callback);
  
end
function handles = createSimulationParamsUI(handles, numberOfSimulations, numberOfSteps, initialNumberOfCells, percentageMesenchymalCells)
  boxX = 0.70;
  textWidth = boxX - 0.03;
  boxWidth = 1 - boxX - 0.02;
  height = 0.15;
  
  firstLineY = 0.75;
  handles.numberOfSimulationsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 firstLineY textWidth height], 'string', 'Number of simulations:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.numberOfSimulations = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX firstLineY boxWidth height], 'string', num2str(numberOfSimulations), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @numberOfSimulations_Callback);
  
  
  secondLineY = 0.55;
  handles.numberOfStepsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 secondLineY textWidth height], 'string', 'Number of steps:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.numberOfSteps = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX secondLineY boxWidth height], 'string', num2str(numberOfSteps), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @numberOfSteps_Callback);
  
  thirdLineY = 0.35;
  handles.initialNumberOfCellsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 thirdLineY textWidth height], 'string', 'Initial number of cells:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.initialNumberOfCells = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX thirdLineY boxWidth height], 'string', num2str(initialNumberOfCells), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @initialNumberOfCells_Callback);
  
  fourthLineY = 0.15;
  handles.percentageMesenchymalCellsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 fourthLineY textWidth height], 'string', '% of M cells [0-100]:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.percentageMesenchymalCells = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX fourthLineY boxWidth height], 'string', num2str(percentageMesenchymalCells), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @percentageMesenchymalCells_Callback);
end
function handles = createDishParamsUI(handles, dishSize, dishHeight)
  boxX = 0.70;
  textWidth = boxX - 0.03;
  boxWidth = 1 - boxX - 0.02;
  height = 0.20;
  
  firstLineY = 0.60;
  handles.dishSizeText = uicontrol ('parent', handles.dishPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 firstLineY textWidth height], 'string', 'Dish size:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.dishSize = uicontrol ('parent', handles.dishPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX firstLineY boxWidth height], 'string', num2str(dishSize), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @dishSize_Callback);
  
  
  secondLineY = 0.30;
  handles.dishHeightText = uicontrol ('parent', handles.dishPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 secondLineY textWidth height], 'string', 'Dish height:', 'fontsize',10, 'horizontalalignment', 'left');
  
  handles.dishHeight = uicontrol ('parent', handles.dishPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX secondLineY boxWidth height], 'string', num2str(dishHeight), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @dishHeight_Callback);
end

% ------------------------- METHODS ---------------------------

function [ bool ] = iscorrectnumber(value)
  if isnan(value)
    bool = false;
  elseif isempty(value)
    bool = false;
  elseif ~strcmp(num2str(size(value)), num2str([1 1]))
    bool = false;
  else
    bool = true;
  end

end


function [ bool ] = iscorrectnumberarray(value)
  if isnan(value)
    bool = false;
  elseif ~isvector(value)
    bool = false;
  else
    bool = true;
  end

end


function [ value ] = getFromConfigOrDefault(name, defaultValue)
  value = defaultValue;
  if exist('config.ini', 'file')
    fileID = fopen('config.ini', 'r');
    lines = strsplit(fscanf(fileID, '%s'),{':', ';'});
    for i = 1:length(lines)/2
      currentArg = char(lines((i-1)*2+1));
      if (strcmp(currentArg,name))
        value = char(lines(i*2));
      elseif (strcmp(currentArg, 'END'))
        break;
      end
    end
  end

end


function backupConfig(rootFolder, handles)

  backupFileID = fopen(strcat(rootFolder, 'config.ini'), 'wt');
    
  fprintf(backupFileID, 'SAVE_SNAPSHOTS : %s;\n', get(handles.dishSnapshots, 'value'));
  fprintf(backupFileID, 'SAVE_3D_SNAPSHOTS : %s;\n', get(handles.dish3DSnapshots, 'value'));
  fprintf(backupFileID, 'BIRTH : %s;\n', get(handles.birth, 'string'));
  fprintf(backupFileID, 'MIN_SURVIVAL : %s;\n', get(handles.minimumSurvival, 'string'));
  fprintf(backupFileID, 'MAX_SURVIVAL : %s;\n', get(handles.maximumSurvival, 'string'));
  fprintf(backupFileID, 'NB_STEPS : %s;\n', get(handles.numberOfSteps, 'string'));
  
  snapshotSteps = get(handles.snapshotSteps, 'string');
  if(isempty(snapshotSteps))
    fprintf(backupFileID, 'SNAPSHOT_STEPS : %s;\n', snapshotSteps);
  end
  
  percentageMesenchymalCells = get(handles.percentageMesenchymalCells, 'string');
  if(isempty(percentageMesenchymalCells))
    fprintf(backupFileID, 'PERCENTAGE_MESENCHYMAL : %s;\n', percentageMesenchymalCells);
  end
  
  fprintf(backupFileID, 'DISH_SIZE : %s;\n', get(handles.dishSize, 'string'));
  fprintf(backupFileID, 'DISH_HEIGHT : %s;\n', get(handles.dishHeight, 'string'));
  fprintf(backupFileID, 'NB_SIMULATIONS : %s;\n', get(handles.numberOfSimulations, 'string'));
  fprintf(backupFileID, 'INIT_NB_CELLS : %s;\n', get(handles.initialNumberOfCells, 'string'));
    
  fprintf(backupFileID, 'END;');
  fclose(backupFileID);

end


function [ string ] = numberArray2String(numbers) 
  string = regexprep(num2str(numbers), '\s*', ', ');

end


function [ string ] = bool2OnOff(bool)
  if(bool)
      string='ON';
  else
      string='OFF';
  end

end


% ------------------------- CALLBACKS ---------------------------

function numberOfSimulations_Callback(hObject, init)
  
  handles = guidata (hObject);

  numberOfSimulations = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(numberOfSimulations)
    set(hObject, 'string', '1');
    errordlg('The number of simulations to execute must be a number', 'Error');
  elseif numberOfSimulations < 1
    set(hObject, 'string', '1');
    errordlg('The number of simulations to execute must be superior to 0', 'Error');
  else
    set(hObject, 'string', num2str(numberOfSimulations));
  end

  guidata(hObject, handles)

end


function numberOfSteps_Callback(hObject, init)
  
  handles = guidata (hObject);

  numberOfSteps = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(numberOfSteps)
    set(hObject, 'string', '1');
    errordlg('The number of steps of each simulations must be a number', 'Error');
  elseif numberOfSteps < 1
    set(hObject, 'string', '1');
    errordlg('The number of steps of each simulations to execute must be superior to 0', 'Error');
  else
    set(hObject, 'string', num2str(numberOfSteps));
  end

  guidata(hObject, handles)
  end


function initialNumberOfCells_Callback(hObject, init)
  
  handles = guidata (hObject);

  initialNumberOfCells = str2num(get(hObject, 'string'));
  if ~iscorrectnumber(initialNumberOfCells)
    set(hObject, 'string', '0');
    errordlg('The initial number of cells of the dish must be a number', 'Error');
  else
    set(hObject, 'string', num2str(initialNumberOfCells));
  end
  guidata(hObject, handles)

end

function percentageMesenchymalCells_Callback(hObject, init)
  
  handles = guidata (hObject);

  percentageMesenchymalCells = str2num(get(hObject, 'string'));

  if ~iscorrectnumberarray(percentageMesenchymalCells)
    set(hObject, 'string', '');
    errordlg('The percentage of mesenchymal cells at start must be an array of numbers', 'Error');
  else
    set(hObject, 'string', num2str(percentageMesenchymalCells));
  end

  guidata(hObject, handles)

end


function birth_Callback(hObject, init)
  
  handles = guidata (hObject);

  birth = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(birth)
    set(hObject, 'string', '0');
    errordlg('The number of living neighbor cell required for a empty/dead cell to become alive must be a number.', 'Error');
  elseif birth < 0
    set(hObject, 'string', num2str(0));
    errordlg('The number of living neighbor cell required for a empty/dead cell to become alive must be superior or equal to the 0.', 'Error');
  else
    set(hObject, 'string', num2str(birth));
  end
  guidata(hObject, handles)

end


function snapshotSteps_Callback(hObject, init)
  
  handles = guidata (hObject);

  snapshotSteps = str2num(get(hObject, 'string'));

  if ~iscorrectnumberarray(snapshotSteps)
    set(hObject, 'string', '');
    errordlg('The steps when a snapshot will be made must be a comma separated array of numbers', 'Error');
  else
    set(hObject, 'string', num2str(snapshotSteps));
  end

  guidata(hObject, handles)

end


function dishSize_Callback(hObject, init)
  
  handles = guidata (hObject);

  dishSize = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(dishSize)
    set(hObject, 'string', '1');
    errordlg('The size of the dish must be a number', 'Error');
  elseif dishSize < 1
    set(hObject, 'string', '1');
    errordlg('The size of the dish must be superior to 0', 'Error');
  else
    set(hObject, 'string', num2str(dishSize));
  end

  guidata(hObject, handles)

end


function dishHeight_Callback(hObject, init)
  
  handles = guidata (hObject);

  dishHeight = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(dishHeight)
    set(hObject, 'string', '1');
    errordlg('The height of the dish must be a number', 'Error');
  elseif dishHeight < 1
    set(hObject, 'string', '1');
    errordlg('The height of the dish must be superior to 0', 'Error');
  else
    set(hObject, 'string', num2str(dishHeight));
  end

  guidata(hObject, handles)

end


function minimumSurvival_Callback(hObject, init)
  
  handles = guidata (hObject);

  maximumSurvival = str2num(get(handles.maximumSurvival, 'string'));
  minimumSurvival = str2num(get(hObject, 'string'));

  if ~iscorrectnumber(minimumSurvival)
    set(hObject, 'string', '0');
    errordlg('The minimum number of living neighbor cell required for a living cell to survive must be a number.', 'Error');
    minimumSurvival = 0;
  elseif minimumSurvival > maximumSurvival
    set(hObject, 'string', num2str(maximumSurvival));
    errordlg('The minimum number of living neighbor cell required for a living cell to survive must be inferior or equal to the maximum.', 'Error');
    minimumSurvival = maximumSurvival;
  else
    set(hObject, 'string', num2str(minimumSurvival));
  end

  set(handles.survival, 'string', char(strcat(num2str(minimumSurvival), {' to '}, num2str(maximumSurvival))));

  guidata(hObject, handles)

end


function maximumSurvival_Callback(hObject, init)
  
  handles = guidata (hObject);

  maximumSurvival = str2num(get(hObject, 'string'));
  minimumSurvival = str2num(get(handles.minimumSurvival, 'string'));

  if ~iscorrectnumber(maximumSurvival)
    set(hObject, 'string', num2str(0));
    errordlg('The maximum number of living neighbor cell required for a living cell to survive must be a number.', 'Error');
    maximumSurvival = 0;
  elseif maximumSurvival < minimumSurvival
    set(hObject, 'string', num2str(minimumSurvival));
    errordlg('The maximum number of living neighbor cell required for a living cell to survive must be superior or equal to the minimum.', 'Error');
    maximumSurvival = minimumSurvival;
  else
    set(hObject, 'string', num2str(maximumSurvival));
  end

  set(handles.survival, 'string', char(strcat(num2str(minimumSurvival), {' to '}, num2str(maximumSurvival))));

  guidata(hObject, handles)

end

% -------------------- BUTTONS CALLBACKS -----------------------


function runSimulationButton_Callback(obj, init)

  global workFolder;
  rootFolder = strcat(workFolder, '/CancerAM_Simulations/');
  date = datestr(now, 'yyyy-mm-dd_HHMMSS');
  dataFolder = strcat(rootFolder,date, '/');
  
  handles = guidata(obj);
  
  mkdir(rootFolder);
  mkdir(dataFolder);
  backupConfig(dataFolder, handles);
  startSimulations(dataFolder, handles);

end


% ------------------- MODEL METHOD -----------------------------

function startSimulations(rootFolder, handles)

%known conditions with their gamma distribution parameters
%cond:  WT      TR    	TR+BIM
%mean:  1       0.59  	0.05
%std :  0.05  	0.029 	0.012
%these number are obtained from the model made in the following article :
%   Piras V, Hayashi K, Tomita M, & Selvarajoo K, 
%   �Investigation of stochasticity in TRAIL signaling cancer model� (2012) 
%   Proc. IEEE/ICME Com. Med. Eng.; pp609-614. 

%cond:          WT      TR    	TR+BIM
%mesenchymal %: 0.02    0.10    0.95

  names = {'WT' 'TRAIL' 'TR+BIM'};
  colors = 'rbg';
  means = [1  0.59 0.05];
  stds = [0.05 0.029 0.012];
  shapes = means.^2./(stds.^2);
  scales = stds.^2./means;
  defaultMesenchymalPercentages = [2, 10, 95];

  % val to init
  enable3DSnapshots = get(handles.dish3DSnapshots, 'Value');

  % is this var really useful? we could disable it if snapshotSteps is empty
  enableSnapshots = get(handles.dishSnapshots, 'Value');

  nbSteps = str2num(get(handles.numberOfSteps, 'string'));
  dishSize = str2num(get(handles.dishSize, 'string'));
  dishHeight = str2num(get(handles.dishHeight, 'string'));
  initNbCells = str2num(get(handles.initialNumberOfCells, 'string'));
  mesenchymalPercentages = str2num(get(handles.percentageMesenchymalCells, 'string'));
  snapshotSteps = [];
  if(enableSnapshots)
    snapshotSteps = str2num(get(handles.snapshotSteps, 'string'));
  end
  nbSimulations = str2num(get(handles.numberOfSimulations, 'string'));
  minSurvival = str2num(get(handles.minimumSurvival, 'string'));
  maxSurvival = str2num(get(handles.maximumSurvival, 'string'));
  survival = minSurvival:maxSurvival;
  birth = str2num(get(handles.birth, 'string'));

  totalNumberOfSimulations = length(names) * nbSimulations * max(length(mesenchymalPercentages),1);

  emptyMesenchymalPercentageInput = isempty(mesenchymalPercentages);

  for k=1:max(length(mesenchymalPercentages),1)
    
    axes(handles.curvesPlot);
    cla reset;
    
    mesenchymalPercentage = 0;
    if(~emptyMesenchymalPercentageInput)
        mesenchymalPercentage = mesenchymalPercentages(k);
    end
    
    curvesData = zeros(length(names),nbSimulations,nbSteps+1);
    
    for j=1:length(names)
      if(emptyMesenchymalPercentageInput)
        mesenchymalPercentage = defaultMesenchymalPercentages(j);
      end
      pts = zeros(nbSimulations,nbSteps+1);
        
      treatmentName = char(names(j));
        
      simulationName = strcat(treatmentName, '_with_',num2str(mesenchymalPercentage), '%MCells');
                
      snapshotFolder = strcat(rootFolder, simulationName, '_snapshots/');

      data = zeros(2,nbSimulations);
      mPercents = zeros(nbSimulations,nbSteps+1);
      for i = 1:nbSimulations
        simulationIndex = i + (j-1)*nbSimulations + (k-1)*length(names)*nbSimulations;
        set(handles.progressText, 'string', strcat('Current simulation: ', simulationName, '(', num2str(simulationIndex), '/', num2str(totalNumberOfSimulations), ')'));
        drawnow;
            
        %pS = makedist('Gamma', 'a',shapes(j), 'b',scales(j));
            
        [a,b,c]=simulateCancer(enableSnapshots, enable3DSnapshots, dishSize,dishHeight,initNbCells,snapshotSteps,shapes(j),scales(j),survival, birth,mesenchymalPercentage,snapshotFolder,nbSteps);
            
        data(1,i) = a;
        data(2,i) = b(nbSteps+1)/min(b);
            
        pts(i,:) = b;
            
        plot(0:nbSteps,b(:), 'Color',colors(j), 'LineWidth',5);hold on;
        drawnow;
            
        mPercents(i,:)=c;
      end
      curvesData(j,:,:) = pts;

      % save of the workspace's data(ratio/simu, growth rate /simu) and pts(nb of cells per steps / simu) variables
      save(strcat(rootFolder, simulationName, '.mat'), 'data', 'pts', 'mPercents');
    end
    
    if(emptyMesenchymalPercentageInput)
      saveFigure(rootFolder, names, colors, curvesData, '');
    else
      saveFigure(rootFolder, names, colors, curvesData, num2str(mesenchymalPercentage));
    end
  end

  set(handles.progressText, 'string', strcat(num2str(totalNumberOfSimulations), ' done.'));
  drawnow;

end


function saveFigure(rootFolder, names, colors, points, mesenchymalPercentage)

  global isMatlab;
  if(isMatlab)
    f=figure('visible', 'off');
  else
    f=figure();
  end
  for i=1:length(names)
    for j=1:size(points, 2)
      pts = points(i,j,:);
      plot(0:(length(pts)-1),pts(:), 'Color',colors(i), 'LineWidth',5);hold on;
    end
  end
  if isempty(mesenchymalPercentage)
      saveas(f,strcat(rootFolder, '/curves.png'));
  else
      saveas(f,strcat(rootFolder, '/curves_with_',mesenchymalPercentage, '%MCells.png'));
  end
  close(f);

end
