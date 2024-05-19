% Script for plotting the results of LTI system
% Created by Arthur Lots on 29 March 2024

%This file will use the data created in DataAcquisition.m to plot the
%impulse responses

%Series 1:
%All stages for 1 condition in absolute timescale
close all

for k = 1:numel(CondNames)
    figure                          %Each condition will get 1 plot
    sgtitle('Impulsive response from real distribution')
    for i = 1:numel(StageNames)
        
        %Get data
        TimeLC = LifeCycleArray(i+(k-1)*LenStageNames, 3);
        IR_LC = LifeCycleArray(i+(k-1)*LenStageNames, 2);
        
        %Plot
        subplot(ceil(LenStageNames/2),2,i);
        hold on
        stairs(TimeLC{1}, IR_LC{1}, '--', 'Color', 'blue', 'LineWidth', 1.25)

        %Create title
        titleName = [StageNames{i} ' ' CondNames{k}];
        title(titleName)
        xlabel('Time (days)')
        ylabel('New')
        hold off

    end
end
%% 

%Series 2:
%Detailed plot of every stage for every condition in relative timescale.
%Impulse response from real data versus experimental

for k = 1:numel(CondNames)
    for i = 1:numel(StageNames)

        %Get Data
        ImpulseTime = ImpulseDataArray(i+(k-1)*LenStageNames, 2);
        IR_Data = ImpulseDataArray(i+(k-1)*LenStageNames, 1);
        Total = RawDataArray(i+(k-1)*LenStageNames,2);
        ExperimentData = RawDataArray(i+(k-1)*LenStageNames,1);
        TimeUnit = 1:length(ExperimentData{1});

        %Plot
        figure
        hold on

        stairs(ImpulseTime{1}, IR_Data{1} * Total{1}, '--', 'Color', 'blue', 'LineWidth', 1.25)
        scatter(TimeUnit, ExperimentData{1}, 'filled', 'Color', 'green')

        %Create title
        titleName = ['Stage ' StageNames{i} ' ' CondNames{k}];
        title(titleName)
        legend('Impulsive response from real distribution', 'Experimental data')
        xlabel('Time (days)')
        ylabel('New to stage')
        xlim([-inf length(ImpulseTime{1})+5]) %Otherwise, it shows 365 days, which is not necessary
    end
end

%% 

%Series 3:
%Detailed plot of every stage for every condition.
%Simulations of the whole life cycle using the composition of the transfer functions

for k = 1:numel(CondNames)
    for i = 1:numel(StageNames)

        %Get Data
        LifeCycleTime = LifeCycleArray(i+(k-1)*LenStageNames, 3);
        LifeCycleIR = LifeCycleArray(i+(k-1)*LenStageNames, 2);

        %Plot
        figure
        hold on
        
        stairs(LifeCycleTime{1}, LifeCycleIR{1}, '--', 'Color', 'blue', 'LineWidth', 1.25)
%         stairs(TimeLifeCycle_LifTab_E18, IR_LifeCycle_LifTab_Eggs_18, 'Color', 'red')

        %TO DO
        %bar(linspace(1, length(WLF_Eggs_18), length(WLF_Eggs_18)), WLF_Eggs_18, 'g', 'FaceAlpha', 0.2, BarWidth = 0.3)
        
        %Create title
        titleName = ['Whole Life Cycle ' StageNames{i} ' ' CondNames{k}];
        title(titleName)
        legend('Impulsive response from real distribution')
%         legend('Impulsive response from real distribution', ['Impulsive response ' ...
%                'from gaussian distribution'], 'Experimental data')
        xlabel('Time (days)')
        ylabel('New to stage')
    end
end