% Script for LTI system of insects
% Created by Arthur Lots on 9 March 2024

% This file takes all data from the excel file and stores the values. 

clear

%Replace these by the titles of the general excel-file
DataFile = 'Life tables test.xlsx';
IndividualLifeHistory = 'Individual-LifeHistory';
PopulationDynamics = 'PopulationDynamics';
CohortGrouping = 'Cohort-grouping';

%Import the names of the stages and conditions.These will be used to create names for all variables. 

StageNames = readcell(DataFile, 'Sheet', 'DatasetOverview', 'Range', 'C40:C49'); %Deaths are not used, so not in selection
LenStageNames = length(StageNames);
CondNames = readcell(DataFile, 'Sheet', 'DatasetOverview', 'Range', 'B13:B27');
CondNames = erase(CondNames, "-"); %Otherwise this will create problems later on

    % Convert numeric values to strings (will only be used if the name
    % consists only of numbers)
for i = 1:numel(CondNames)
    if isnumeric(CondNames{i})
        CondNames{i} = num2str(CondNames{i});
    end
end

%Extract data from excel
dataTable = readmatrix(DataFile, 'Sheet', PopulationDynamics, 'Range', 'C12:HA376');

%% 

% Importing dataset 

    % Real data from climatic chamber experiments
    % Here the new individuals in each stage per day are reported
    % The day zero is reset for each stage (scaled population)


    %Create all stage variables and assign data
RawDataArray = cell(LenStageNames*length(CondNames), 2);
for k = 1:numel(CondNames)
    for i = 1:numel(StageNames)
            % Form variable name
            varName = [StageNames{i} '_' CondNames{k}];
            
            % Assign data to the dynamically created variable
            eval([varName ' = dataTable(:, i+(k-1)*14);']);

            % Total insects per condition (survived from egg to adult)
            % This is for checking purposes and to normalize data
            totalVar = ['Total' varName];
            eval([totalVar ' = sum(eval(varName));']);

            %For callback purposes:
            RawDataArray(i+(k-1)*LenStageNames, 1:2) = {eval(varName), eval(totalVar)};
    end
end

%% 

% Normalization of the raw data (Data/TotalOfData = Normalised)
NormDataArray = cell(LenStageNames*length(CondNames), 2);
for k = 1:numel(CondNames)
    for i = 1:numel(StageNames)
            % Form variable name
            NormName = ['Norm_' StageNames{i} '_' CondNames{k}];
            TimeUnitName = ['TimeUnits_' StageNames{i} '_' CondNames{k}];
            
            % Assign data to the dynamically created variable
            Total = RawDataArray(i+(k-1)*LenStageNames,2);
            Data = RawDataArray(i+(k-1)*LenStageNames,1);
            eval([NormName ' = Data{1}./Total{1};']);
            eval([TimeUnitName ' = linspace(1, length(eval(NormName)), length(eval(NormName)));']);

            %For callback purposes:
            NormDataArray(i+(k-1)*LenStageNames, 1:2) = {eval(NormName), eval(TimeUnitName)};
    end
end

%% 


% Second part - Calculation of the transfer functions and impulse reponses
% This first part concerns ONLY the data

    % Definition of the transfer function - This is good for the whole
    % code, not only for what follows strictly below

z = tf([1 0], [1], 1);
    
    %Calculate Impulse responses

ImpulseDataArray = cell(LenStageNames*length(CondNames), 3);
for k = 1:numel(CondNames)
    for i = 1:numel(StageNames)
            % Form variable name
            IRName = ['IR_' StageNames{i} '_' CondNames{k}];
            TimeName = ['Time_' StageNames{i} '_' CondNames{k}];
            OutData = ['Out_' StageNames{i} '_' CondNames{k}];
            
            % Assign data to the dynamically created variable
            NormData = NormDataArray(i+(k-1)*LenStageNames, 1);
            [IR_Data, IR_Time, FirstData] = Functions.ImpResp(NormData{1}, z); %See Functions.m
            eval([IRName ' = IR_Data;']);
            eval([TimeName ' = IR_Time;']);
            eval([OutData ' = FirstData;']);

            %For callback purposes:
            ImpulseDataArray(i+(k-1)*LenStageNames, 1:3) = {eval(IRName), eval(TimeName), eval(OutData)};
    end
end

%% 

% Simulation of the whole life cycle


    % Multiplication of the transfer functions from the stage of interest
    % to the lower ones!!
    % We have to consider the total eggs enter in the life cycle at day
    % zero, for this reason it is multiplied by the number of eggs!

    % From REAL data
LifeCycleArray = cell(LenStageNames*length(CondNames), 3);
for k = 1:numel(CondNames)
    T = RawDataArray(1+(k-1)*LenStageNames,2);  % Start value = TotalEgg of condition
    T = T{1};                                   % Get value out of cell
    for i = 1:numel(StageNames)
        % Form variable name
        LifeCycleName = ['LifeCycle_' StageNames{i} '_' CondNames{k}];
        IR_LC_Name = ['IR_LifeCycle_' StageNames{i} '_' CondNames{k}];
        Time_LC_Name = ['Time_LifeCycle_' StageNames{i} '_' CondNames{k}];
        
        %Calculations
        Out = ImpulseDataArray(i+(k-1)*LenStageNames,3);    % Out = transfer function of stage
        T = T*Out{1};                           % Example: LifeCycle_L1_C1 = TotalE_C1 * (OutE_C1 * OutL1_C1);
        [IR_Data, IR_Time] = impulse(T);        % Impulse respons of the life cycle

        %Assign data to variables
        eval([LifeCycleName ' = T;']);
        eval([IR_LC_Name ' = IR_Data;']);
        eval([Time_LC_Name ' = IR_Time;']);
                
        %For callback purposes:
        LifeCycleArray(i+(k-1)*LenStageNames, 1:3) = {eval(LifeCycleName), eval(IR_LC_Name), eval(Time_LC_Name)};
    end
end
