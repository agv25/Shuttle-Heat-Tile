% appShuttle.mlapp
% Script that uses MATLAB appdesigner with shuttleEnhanced.m and
% testThickness.m for GUI
% created by Alex Varney 15/04/2021

classdef appShuttle < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Image                           matlab.ui.control.Image
        UpdateButton                    matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        TilePropertiesTab               matlab.ui.container.Tab
        SpecificHeatJkgKEditField       matlab.ui.control.NumericEditField
        SpecificHeatJkgKLabel           matlab.ui.control.Label
        Densitykgm3EditField            matlab.ui.control.NumericEditField
        Densitykgm3Label                matlab.ui.control.Label
        ThermalConductivityWmKEditField  matlab.ui.control.NumericEditField
        ThermalConductivityWmKEditFieldLabel  matlab.ui.control.Label
        ModelPropertiesTab              matlab.ui.container.Tab
        MethodDropDown                  matlab.ui.control.DropDown
        MethodDropDownLabel             matlab.ui.control.Label
        NoofSpatialStepsnxEditField     matlab.ui.control.NumericEditField
        NoofSpatialStepsnxEditFieldLabel  matlab.ui.control.Label
        NoofTimeStepsntEditField        matlab.ui.control.NumericEditField
        NoofTimeStepsntEditFieldLabel   matlab.ui.control.Label
        MaxTimetmaxsEditField           matlab.ui.control.NumericEditField
        MaxTimetmaxsEditFieldLabel      matlab.ui.control.Label
        TestTileTab                     matlab.ui.container.Tab
        OptimalTileThicknessmEditField  matlab.ui.control.NumericEditField
        OptimalTileThicknessmEditFieldLabel  matlab.ui.control.Label
        MaxTempatInnerSurfacedegCEditField  matlab.ui.control.NumericEditField
        MaxTempatInnerSurfacedegCEditFieldLabel  matlab.ui.control.Label
        TileLocationDropDown            matlab.ui.control.DropDown
        TileLocationDropDownLabel       matlab.ui.control.Label
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            % Define all function inputs
            tmax = app.MaxTimetmaxsEditField.Value;
            nt = app.NoofTimeStepsntEditField.Value;
            nx = app.NoofSpatialStepsnxEditField.Value;
            method = app.MethodDropDown.Value;
            location = app.TileLocationDropDown.Value;
            maxT = app.MaxTempatInnerSurfacedegCEditField.Value;
            thermCon = app.ThermalConductivityWmKEditField.Value;
            density = app.Densitykgm3EditField.Value;
            specHeat = app.SpecificHeatJkgKEditField.Value;
            
            % Run testThickness.m
            [optimalThickness] = testThickness(thermCon, density, specHeat, maxT, location, false);
            app.OptimalTileThicknessmEditField.Value = optimalThickness; 
                                    
            % Run shuttle.m with optimalThickness
            [x,t,u] = shuttleEnhanced(thermCon, density, specHeat, tmax, nt, optimalThickness, nx, method, location, false);
                        
            % Plot Shuttle on axes 1
            waterfall(app.UIAxes, x,t,u);
            view(app.UIAxes, 140, 30); % rotate the view
            xlabel(app.UIAxes, '\itx\rm (m)');
            xlim(app.UIAxes, [0 optimalThickness]);
            ylabel(app.UIAxes,'\itt\rm (s)');
            zlabel(app.UIAxes, ['\itu\rm (' char(176) 'C)']);
            grid(app.UIAxes, 'on');
            title(app.UIAxes, ['Temperature Variation of Tile ', location]);
            
            % Plot testThickness.m on axes 2
            cla(app.UIAxes2);  % clear last plot
            plot(app.UIAxes2, t, u(:,end), 'r'); % inner temp
            hold(app.UIAxes2, "on");  % keep last plots
            plot(app.UIAxes2, t, u(:,1), 'b'); % outer temp 
            plot(app.UIAxes2, [0, max(t)], [maxT, maxT], 'k--'); % maxT
            xlabel(app.UIAxes2, 'Time, t (s)');
            ylabel(app.UIAxes2, ['Temperature, u (', char(176), 'C)']);
            title(app.UIAxes2, ['Outer Surface - Blue, ' ...
                'Inner Surface - Red']);
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1153 736];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [54 406 465 299];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [618 52 462 296];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [583 480 498 214];

            % Create TilePropertiesTab
            app.TilePropertiesTab = uitab(app.TabGroup);
            app.TilePropertiesTab.Title = 'Tile Properties';

            % Create ThermalConductivityWmKEditFieldLabel
            app.ThermalConductivityWmKEditFieldLabel = uilabel(app.TilePropertiesTab);
            app.ThermalConductivityWmKEditFieldLabel.HorizontalAlignment = 'right';
            app.ThermalConductivityWmKEditFieldLabel.Position = [59 139 166 22];
            app.ThermalConductivityWmKEditFieldLabel.Text = 'Thermal Conductivity (W/mK):';

            % Create ThermalConductivityWmKEditField
            app.ThermalConductivityWmKEditField = uieditfield(app.TilePropertiesTab, 'numeric');
            app.ThermalConductivityWmKEditField.Position = [240 139 100 22];
            app.ThermalConductivityWmKEditField.Value = 0.0577;

            % Create Densitykgm3Label
            app.Densitykgm3Label = uilabel(app.TilePropertiesTab);
            app.Densitykgm3Label.HorizontalAlignment = 'right';
            app.Densitykgm3Label.Position = [127 89 98 22];
            app.Densitykgm3Label.Text = 'Density (kg/m^3):';

            % Create Densitykgm3EditField
            app.Densitykgm3EditField = uieditfield(app.TilePropertiesTab, 'numeric');
            app.Densitykgm3EditField.Position = [240 89 100 22];
            app.Densitykgm3EditField.Value = 144;

            % Create SpecificHeatJkgKLabel
            app.SpecificHeatJkgKLabel = uilabel(app.TilePropertiesTab);
            app.SpecificHeatJkgKLabel.HorizontalAlignment = 'right';
            app.SpecificHeatJkgKLabel.Position = [104 41 121 22];
            app.SpecificHeatJkgKLabel.Text = 'Specific Heat (J/kgK):';

            % Create SpecificHeatJkgKEditField
            app.SpecificHeatJkgKEditField = uieditfield(app.TilePropertiesTab, 'numeric');
            app.SpecificHeatJkgKEditField.Position = [240 41 100 22];
            app.SpecificHeatJkgKEditField.Value = 1261;

            % Create ModelPropertiesTab
            app.ModelPropertiesTab = uitab(app.TabGroup);
            app.ModelPropertiesTab.Title = 'Model Properties';

            % Create MaxTimetmaxsEditFieldLabel
            app.MaxTimetmaxsEditFieldLabel = uilabel(app.ModelPropertiesTab);
            app.MaxTimetmaxsEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxTimetmaxsEditFieldLabel.Position = [127 110 114 22];
            app.MaxTimetmaxsEditFieldLabel.Text = 'Max. Time, tmax (s):';

            % Create MaxTimetmaxsEditField
            app.MaxTimetmaxsEditField = uieditfield(app.ModelPropertiesTab, 'numeric');
            app.MaxTimetmaxsEditField.Position = [256 110 100 22];
            app.MaxTimetmaxsEditField.Value = 4000;

            % Create NoofTimeStepsntEditFieldLabel
            app.NoofTimeStepsntEditFieldLabel = uilabel(app.ModelPropertiesTab);
            app.NoofTimeStepsntEditFieldLabel.HorizontalAlignment = 'right';
            app.NoofTimeStepsntEditFieldLabel.Position = [120 68 121 22];
            app.NoofTimeStepsntEditFieldLabel.Text = 'No. of Time Steps, nt:';

            % Create NoofTimeStepsntEditField
            app.NoofTimeStepsntEditField = uieditfield(app.ModelPropertiesTab, 'numeric');
            app.NoofTimeStepsntEditField.Position = [256 68 100 22];
            app.NoofTimeStepsntEditField.Value = 501;

            % Create NoofSpatialStepsnxEditFieldLabel
            app.NoofSpatialStepsnxEditFieldLabel = uilabel(app.ModelPropertiesTab);
            app.NoofSpatialStepsnxEditFieldLabel.HorizontalAlignment = 'right';
            app.NoofSpatialStepsnxEditFieldLabel.Position = [107 29 134 22];
            app.NoofSpatialStepsnxEditFieldLabel.Text = 'No. of Spatial Steps, nx:';

            % Create NoofSpatialStepsnxEditField
            app.NoofSpatialStepsnxEditField = uieditfield(app.ModelPropertiesTab, 'numeric');
            app.NoofSpatialStepsnxEditField.Position = [256 29 100 22];
            app.NoofSpatialStepsnxEditField.Value = 51;

            % Create MethodDropDownLabel
            app.MethodDropDownLabel = uilabel(app.ModelPropertiesTab);
            app.MethodDropDownLabel.HorizontalAlignment = 'right';
            app.MethodDropDownLabel.Position = [164 147 49 22];
            app.MethodDropDownLabel.Text = 'Method:';

            % Create MethodDropDown
            app.MethodDropDown = uidropdown(app.ModelPropertiesTab);
            app.MethodDropDown.Items = {'forward', 'backward', 'dufort-frankel', 'crank-nicolson'};
            app.MethodDropDown.Position = [228 147 126 22];
            app.MethodDropDown.Value = 'crank-nicolson';

            % Create TestTileTab
            app.TestTileTab = uitab(app.TabGroup);
            app.TestTileTab.Title = 'Test Tile';

            % Create TileLocationDropDownLabel
            app.TileLocationDropDownLabel = uilabel(app.TestTileTab);
            app.TileLocationDropDownLabel.HorizontalAlignment = 'right';
            app.TileLocationDropDownLabel.Position = [142 139 76 22];
            app.TileLocationDropDownLabel.Text = 'Tile Location:';

            % Create TileLocationDropDown
            app.TileLocationDropDown = uidropdown(app.TestTileTab);
            app.TileLocationDropDown.Items = {'468', '480', '502', '590', '597', '711', '730', '850'};
            app.TileLocationDropDown.Position = [233 139 100 22];
            app.TileLocationDropDown.Value = '597';

            % Create MaxTempatInnerSurfacedegCEditFieldLabel
            app.MaxTempatInnerSurfacedegCEditFieldLabel = uilabel(app.TestTileTab);
            app.MaxTempatInnerSurfacedegCEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxTempatInnerSurfacedegCEditFieldLabel.Position = [44 96 197 22];
            app.MaxTempatInnerSurfacedegCEditFieldLabel.Text = 'Max Temp at Inner Surface (deg C):';

            % Create MaxTempatInnerSurfacedegCEditField
            app.MaxTempatInnerSurfacedegCEditField = uieditfield(app.TestTileTab, 'numeric');
            app.MaxTempatInnerSurfacedegCEditField.Position = [256 96 100 22];
            app.MaxTempatInnerSurfacedegCEditField.Value = 175;

            % Create OptimalTileThicknessmEditFieldLabel
            app.OptimalTileThicknessmEditFieldLabel = uilabel(app.TestTileTab);
            app.OptimalTileThicknessmEditFieldLabel.HorizontalAlignment = 'right';
            app.OptimalTileThicknessmEditFieldLabel.FontSize = 16;
            app.OptimalTileThicknessmEditFieldLabel.FontWeight = 'bold';
            app.OptimalTileThicknessmEditFieldLabel.Position = [76 23 215 34];
            app.OptimalTileThicknessmEditFieldLabel.Text = 'Optimal Tile Thickness (m):';

            % Create OptimalTileThicknessmEditField
            app.OptimalTileThicknessmEditField = uieditfield(app.TestTileTab, 'numeric');
            app.OptimalTileThicknessmEditField.FontSize = 16;
            app.OptimalTileThicknessmEditField.Position = [306 23 100 34];

            % Create UpdateButton
            app.UpdateButton = uibutton(app.UIFigure, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.BackgroundColor = [1 1 0];
            app.UpdateButton.FontSize = 16;
            app.UpdateButton.FontWeight = 'bold';
            app.UpdateButton.Position = [762 389 125 49];
            app.UpdateButton.Text = 'Update';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [56 25 501 365];
            app.Image.ImageSource = 'AllTempData.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = appShuttle

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end