


%--------------------------------------------------------------------------
%--- *label.png map to clinical hair density areas 
%--------------------------------------------------------------------------
%  8 --- hair partition (ie, to be considered normal)
% 10 --- normal
% 20 --- low density
% 28 --- low density, but clinically scalp (eg spurious long hair on scalp)
% 30 --- scalp

% 40 --- other bg to remove (eg, fingers, pins, etc), image intensity 
%        values should already be "0"

clear;
clc;


training_set = [6 9 14 22 28 35 36 40 57 66 80 85 89 104 122 128 159 172 190 230 231 242 249];


files = dir('../imgs/*.png');

file_names_array = strings(length(files), 1);
masks_names_array = strings(length(files), 1);
for i = 1: length(files)
    file_names_array(i) = strcat('../imgs/',files(i).name);
    temp = char(file_names_array(i));
    masks_names_array(i) =  convertCharsToStrings(strcat(...
                         '../masks',temp(8:end-4),'_labels.png'));
end
error = zeros(length(files), 1);


XTrain = [];
YTrain = [];
XTest = [];
YTest = [];

my_indices = randperm(length(files));
neighsize = 3;
trainsize = 200;
rbg_feat = 3;

% Change resolution here
res = 128;
numrows = res;
numcols = res;

%%
for i = 1:length(files)
    if ismember(i, training_set)
        disp(i)
        image_no = (i);

        temp = imread(file_names_array(image_no));
        temp = imresize(temp, [numrows numcols], 'nearest');

        temp_mod = zeros(size(temp, 1)*size(temp, 1), neighsize *neighsize*3 );


        for j = 1:neighsize *neighsize

            filter = zeros(neighsize*neighsize, 1);
            filter(j) = 1;
            filter = reshape(filter, neighsize, neighsize);

            zzz = ordfilt2(temp(:, :, 1), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+1 )  = zzz(:);
            zzz = ordfilt2(temp(:, :, 2), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+2 ) = zzz(:);
            zzz = ordfilt2(temp(:, :, 3), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+3 ) = zzz(:);

        end

        temp = temp_mod;

        test = imread(masks_names_array(image_no));
        test = imresize(test, [numrows numcols], 'nearest');
        
        test = test(:);

        test = 10 * floor(test/10);
        test(test==20) = 30;
        test(test==40) = 10;


        operating_index = test~=0;

        temp = temp(operating_index, :);
        test = test(operating_index);

        XTrain = cat(1, XTrain, temp);
        YTrain = cat(1, YTrain, test);
        
    end
end


%%
for i = 1:length(files)
    % First run with first if statement, save the *.mat files, then comment this line and uncomment the next if statement.
    if ~ismember(i, training_set) %%% keep this line, run the code and save the Xtrain, YTrain, XTest and YTest as their mat files.
	%if ismember(i, training_set) %%% Once generate the mat files, rerun this by commenting the previous if, and uncommenting this line to generate all files for the python file.
        disp(i)
        image_no = (i);

        temp = imread(file_names_array(image_no));
        temp = imresize(temp, [numrows numcols], 'nearest');
        
        
        temp_mod = zeros(size(temp, 1)*size(temp, 1), neighsize *neighsize*3 );

        for j = 1:neighsize *neighsize

            filter = zeros(neighsize*neighsize, 1);
            filter(j) = 1;
            filter = reshape(filter, neighsize, neighsize);

            zzz = ordfilt2(temp(:, :, 1), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+1 )  = zzz(:);
            zzz = ordfilt2(temp(:, :, 2), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+2 ) = zzz(:);
            zzz = ordfilt2(temp(:, :, 3), 1, filter);
            temp_mod(:, (j-1)*rbg_feat+3 ) = zzz(:);

        end

        temp = temp_mod;

        file_to_be_saved = strcat('all_images_converted_patch_mat33/',num2str(i), '.mat')
        save(file_to_be_saved, 'temp')
        
        test = imread(masks_names_array(image_no));
        test = imresize(test, [numrows numcols], 'nearest');
        
        
        test = test(:);

        test = 10 * floor(test/10);
        test(test==20) = 30;
        test(test==40) = 10;

        file_to_be_saved = strcat('all_images_converted_patch_Y/',num2str(i), '.mat')
        save(file_to_be_saved, 'test')
        
        
        operating_index = test~=0;
        temp = temp(operating_index, :);
        test = test(operating_index);

        XTest = cat(1, XTest, temp);
        YTest = cat(1, YTest, test);
end
end
