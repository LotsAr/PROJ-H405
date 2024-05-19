% Script for LTI system of insects
% Created by Arthur Lots on 17 March 2024

%Contains a static class with all the functions to carry out the analysis

classdef Functions

    methods (Static) % Insert any function in between "methods" and "end"
    
    %Impulse repsons calculator
        function [IR_Data, IR_Time, OutData] = ImpResp(DataArray, TransFunc)
            OutData = tf(0); % Initialize OutData as a zero transfer function

            for i = 1 : length(DataArray)
                % Compute the response of TransFunc^(-i) to the input DataArray(i) and add it to the accumulated OutData
                % => Convolving the input signal with the system represented by TransFunc^(-i)
                OutData = OutData + TransFunc^(-i) * DataArray(i);
            end
            
            % Compute the impulse response of the accumulated system OutData
            [IR_Data, IR_Time] = impulse(OutData); % store the solution
        end
        
    end
end