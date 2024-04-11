%% InSAR Info
% * Author:                  Miranda Holloway
% * Date:                    Created 4/2/2023, Last Edited 4/___/2024
%
%% Variables used to test code

clc;
clearvars;
close all;

dir = 'subdir1';
no_x_tix = 3;
no_y_tix = 10;

%% Code (make this a section heading after testing)

filepath = strcat('C:\Users\mmpho\sent_test\',dir,'\');
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


%% Tested code that works only when |no_x_ticks = 5|

% % Remember that |x| values correspond to latitude and |y| values correspond
% % to longitude!
% x_size = dem_rsc{1,2};
% y_size = dem_rsc{2,2};
% x_first = dem_rsc{3,2};
% y_first = dem_rsc{4,2};
% x_step = dem_rsc{5,2};
% y_step = dem_rsc{6,2};
% 
% % Create arrays for axis labels and their corresponding pixels
% x_pix = ones(1,(no_x_tix + 1));
% x_labels = zeros(1,(no_x_tix + 1));
% y_pix = ones(1,(no_y_tix + 1));
% y_labels = zeros(1,(no_y_tix + 1));
% 
% x_spacing = x_size/no_x_tix;
% x_int = 1; % We assume that |x_spacing| is a whole number but will change this below if that is not true
% y_spacing = y_size/no_y_tix;
% y_int = 1; % We assume that |y_spacing| is a whole number but will change this below if that is not true
% 
% if (rem(x_spacing,1) ~= 0)
%     % Then |x| is not a whole number
%     % Round down to ensure that MATLAB doesn't throw an out-of-bounds error
%     x_int = 0;
%     x_spacing = floor(x_spacing);
% end
% if (rem(y_spacing,1) ~= 0)
%     % Do the same thing for |y|
%     y_int = 0;
%     y_spacing = floor(y_spacing);
% end
% 
% if (x_int)
%     % Then we don't have to worry about messing around with the pixel
%     % indices!
%     % Separately deal with the i = 1 case - we know that the |x_first|
%     % latitude value will always correspond to the first pixel of the image
%     % We will not need to edit the first value in the |x_pix| array
%     x_labels(1) = x_first;
% 
%     for i = 2:length(x_pix)
%         x_pix(i) = (i-1)*x_spacing;
%         x_labels(i) = (i-1)*x_spacing*x_step + x_first;
%     end
% else
%     % Now we have to worry about pixel indices... :(
%     % First pixel will always be the |x_start| value
%     % We will not need to edit the first value in the |x_pix| array
%     x_labels(1) = x_first;
% 
%     % Define the value for the last pixel
%     x_pix(end) = x_size;
%     x_labels(end) = x_size*x_step + x_first;
% 
%     % We will use pixel values closer to either the 1st or last pixel
%     % depending on whether they are on the left or right half of the image
%     half = x_size/2;
%     for i = 2:(length(x_pix)-1)
%         x_pix(i) = (i-1)*x_spacing;
% 
%         if (x_pix(i) > half)
%             % Then place pixels closer to the end of the image
%             x_pix(i) = x_size - (length(x_pix)-i)*x_spacing;
%             x_labels(i) = x_labels(end) - (length(x_pix)-i)*x_spacing*x_step;
%         else
%             % Simply calculate |x_labels| value
%             x_labels(i) = x_first + (i-1)*x_spacing*x_step;
%         end
%     end
% end
% 
% x_labels = round(x_labels,2);
