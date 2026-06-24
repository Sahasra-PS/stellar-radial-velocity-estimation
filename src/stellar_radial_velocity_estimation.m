% Stellar Radial Velocity Estimation
% Author: Sahasra P S
% Description:
% Estimates stellar radial velocities from observed H-alpha wavelength shifts using the Doppler effect.
% Dataset: starData.mat
% Rest wavelength of H-alpha = 656.28 nm


load starData

% define physical constants
c = 299792.458; 
lambdaHa = 656.28; 

% construct wavelength axis from the dataset
nObs = size(spectra,1);
lambdaStart = 630.02;
lambdaDelta = 0.14;
lambdaEnd = lambdaStart + (nObs - 1) * lambdaDelta;

lambda = lambdaStart : lambdaDelta : lambdaEnd;

% plot spectra of all seven stars
for i = 1:7
    spec = spectra(: , i);
    plot(lambda , spec);
    hold on
end
xlabel("Wavelength(nm)");
ylabel("Light Intensity");
title("Spectra of Selected Stars");
legend(starnames);
grid on;
hold off

velocities = zeros(7,1);
HaValues = zeros(7,1);
motionType = strings(7,1);

% determine h-alpha position and radial velocity
for star = 1:7
    s = spectra(: , star);
    figure;
    subplot(211);
    plot(lambda , s);
    hold on

    % restrict search to h-alpha region
    region = (lambda > 654) & (lambda < 658);
    sRegion = s(region);
    lambdaRegion = lambda(region);

    [sHa , idx] = min(sRegion);
    lambdaHaObs = lambdaRegion(idx);
    
    plot(lambdaHaObs , sHa , "rs");
    xlabel("Wavelength(nm)");
    ylabel("Light Intensity");
    xline(lambdaHaObs , "--b" , 'Observed H\alpha');
    title(starnames(star) + " Spectrum");
    grid on;
    hold off
    
    subplot(212);
    plot(lambda , s, lambdaHaObs , sHa , "rs");
    xlabel("Wavelength(nm)");
    ylabel("Light Intensity");
    xline(656.28 , "--r" , 'Rest H\alpha');
    xline(lambdaHaObs , "--b" , 'Observed H\alpha');
    title("Comparison with Rest H\alpha");
    xlim([654 659]);
    grid on;

    % doppler shift relation
    lambdaShift = (lambdaHaObs / lambdaHa) - 1;
    radialVelocity = lambdaShift * c;

    if radialVelocity > 0
        shiftType = "Redshifted";
    else
        shiftType = "Blueshifted";
    end

    velocities(star) = radialVelocity;
    HaValues(star) = lambdaHaObs;
    motionType(star) = shiftType;
      
end

% visual representation with table and bar graph
t = table(categorical(starnames) , velocities , HaValues , categorical(motionType) , ...
    'VariableNames' , {'Star Name' , 'Radial Velocity(km/s)' , 'H-alpha Wavelength(nm)' , 'Shift'});
disp(t)

figure;
b = bar(t , "Star Name" , "Radial Velocity(km/s)");
title("Comparison of Stellar Radial Velocities");
b.FaceColor = 'flat';

shift = zeros(length(velocities),3);
for i = 1 : length(velocities)
    if velocities(i) > 0
        shift(i , :) = [1 0.4 0.3];
    else
        shift(i , :) = [0.3 0.5 1];
    end
end
b.CData = shift;

hold on
red = patch(NaN , NaN , [1 0.4 0.3]);
blue = patch(NaN , NaN , [0.3 0.5 1]);
legend([red , blue] , {"Redshifted(Moving Away)" , "Blueshifted(Moving Toward Us)"} ...
    , "Location" , "northwest");
hold off
grid on;