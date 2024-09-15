%% InSAR Info
% * Author:                  Miranda Holloway
% * Date:                    Created 4/2/2023, Last Edited 4/11/2024
%

%% Code (make this a section heading after testing)

function [pix_out,labels_out] = igram_latlong(subdir, no_x_tix, no_y_tix)
filepath = strcat('C:\Users\mmpho\sent_test\',subdir,'\');
addpath(filepath);

% Read dem.rsc to get image size
dat = split(fileread(strcat(filepath,'dem.rsc')));
dem_rsc = cell(((length(dat)-1)/2),2);
idx = 1;
for i = 1:(length(dat) - 1)
    if (mod(i,2) == 0)
        % Index is even
        % Value itself
        dem_rsc{idx,2} = str2double(dat{i});
        idx = idx + 1;
    else
        % Index is odd
        % Value title
        dem_rsc{idx,1} = dat{i};
    end
end

% Arrays will always label the first pixel's lat/long so add 1 to the
% no_tix parameters
no_x_tix = no_x_tix + 1;
no_y_tix = no_y_tix + 1;

% Establish an array to hold the pixels and the latitude/longitude values
% for the |x| and |y| directions
% Note that |x| will always correspond to the first row and |y| will always
% correspond to the second row
pix = NaN(2,max([no_x_tix no_y_tix]));
labels = NaN(2,max([no_x_tix no_y_tix]));

% First pixel is always 1
pix(:,1) = 1;
% Good place to comment if u need debug
for idx = [1 2]
    % 0 = |x|, 1 = |y|

    % Remember that |x| values correspond to latitude and |y| values correspond
    % to longitude!
    img_size = dem_rsc{1+idx-1,2};
    first = dem_rsc{3+idx-1,2};
    step = dem_rsc{5+idx-1,2};

    % Create arrays for axis labels and their corresponding pixels
    if (idx == 1)
        % Working with |x| data
        % pix = ones(1,(no_x_tix + 1));
        % labels = zeros(1,(no_x_tix + 1));
        no_tix = no_x_tix;
        spacing = img_size/(no_x_tix - 1);
    elseif (idx == 2)
        % Working with |y| data
        % pix = ones(1,(no_y_tix + 1));
        % labels = zeros(1,(no_y_tix + 1));
        no_tix = no_y_tix;
        spacing = img_size/(no_y_tix - 1);
    end
    integer = 1; % We assume that |spacing| is a whole number but will change this below if that is not true

    if (rem(spacing,1) ~= 0)
        % Then |spacing| is not a whole number
        % Round down to ensure that MATLAB doesn't throw an out-of-bounds error
        integer = 0;
        spacing = floor(spacing);
    end

    if (integer)
        % Then we don't have to worry about messing around with the pixel
        % indices!
        % Separately deal with the i = 1 case - we know that the |x_first|
        % latitude value will always correspond to the first pixel of the image
        labels(idx,1) = first;

        for i = 2:no_tix
            pix(idx,i) = (i-1)*spacing;
            labels(idx,i) = (i-1)*spacing*step + first;
        end
    else
        % Now we have to worry about pixel indices... :(
        % First pixel will always be the |x_start| value
        labels(idx,1) = first;

        % Define the value for the last pixel
        pix(idx,no_tix) = img_size;
        labels(idx,no_tix) = img_size*step + first;

        % We will use pixel values closer to either the 1st or last pixel
        % depending on whether they are on the left or right half of the image
        half = img_size/2;
        for i = 2:(no_tix-1)
            pix(idx,i) = (i-1)*spacing;

            if (pix(idx,i) > half)
                % Then place pixels closer to the end of the image
                pix(idx,i) = img_size - (no_tix-i)*spacing;
                labels(idx,i) = labels(idx,no_tix) - (no_tix-i)*spacing*step;
            else
                % Simply calculate |x_labels| value
                labels(idx,i) = first + (i-1)*spacing*step;
            end
        end
    end

end

labels = round(labels,2);

pix_out = pix;
labels_out = labels;
end
