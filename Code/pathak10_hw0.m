% ENPM 673 Perception For Autonomous Robotics
% Warmup Exercise 1
% To detect, count and classify pins according to the color from the given image.
%
% Code By: Mayank Pathak
%          115555037
%
% Dependencies: It uses a function called 'colornames' to obtain the color name from the given [R,G,B]
%               values. There are 6 files (colornames_view.m, colornames_doc.m, colornames_deltaE.m,
%               colornames_cube.m, colornames.mat and colornames.m) which are used for define and use 
%               features of this function. Originally written by Stephen Cobeldick.
%
% Please have the above mentioned files in the same working directory as of
% this code.
%
%% Initializing and Declaring Variables
whitepins = 0;


%% Defining Input image
img = imread('TestImgResized.jpg');
gray = rgb2gray(img);                   % Converted to grayscale

img2 = im2double(img);                  % For double precision
[r2 c2 p2] = size(img);

%% Extract individual planes from RGB plane

imgR = squeeze(img2(:,:,1));
imgG = squeeze(img2(:,:,2));
imgB = squeeze(img2(:,:,3));

%% Thresholding and applying Morphological Operations

edged_prewitt = edge(gray,'prewitt',[],'horizontal');       %edged using Prewitt method
se2 = strel('disk',4);
dilated_prewitt = imdilate(edged_prewitt,se2);
dilated_prewitt = bwareaopen(imfill(dilated_prewitt,'holes'),10);   %fill holes less than 10pixels
dilated_prewitt = bwpropfilt(dilated_prewitt,'Area',[250, 1500]);

%%  Segmented gray-level image

[labels, numLabels] = bwlabel(dilated_prewitt);

%%  Initialize matrices

rLabel = zeros(r2,c2);
gLabel = zeros(r2,c2);
bLabel = zeros(r2,c2);

%% Get average color vector for each labeled region 
numlables = labels;

for i =1: numLabels
    rLabel(labels==i) = median(imgR(labels==i));
    gLabel(labels==i) = median(imgG(labels==i));
    bLabel(labels==i) = median(imgB(labels==i));
end
imLabel = cat(3,rLabel,gLabel,bLabel);
image8Bit = uint8(255 * mat2gray(imLabel));

%% Calculating Centroids for each blob

s = regionprops(dilated_prewitt,'centroid');
centroids = cat(1,s.Centroid);

% figure;
% imshow(img);
% hold on
% plot(centroids(:,1),centroids(:,2),'b*');
% hold off


%% Obtaining Pixel values from image

[r,c] = size(centroids);
for r = 1:r
    pixels(r,:) = impixel(image8Bit,centroids(r,1),centroids(r,2));
end

rgb = pixels/255;
pincolors = colornames('Natural',rgb,'CIE76');
totalpins = numLabels;

pincolors = string(pincolors);

[colors,~,idx] = unique(pincolors);
numOccurrences = histcounts(idx,numel(colors));

[rankOfOccurrences,rankIndex] = sort(numOccurrences,'descend');
ColorByFrequency = colors(rankIndex);

numOccurrences = numOccurrences(rankIndex);
numOccurrences = numOccurrences';

%% Caculating total number of pins
for t = 1:totalpins
    if pincolors(t)== 'White'
        whitepins = whitepins + 1;
    end
end

coloredpins = totalpins - whitepins;

%% Displaying Output

figure;
subplot(2,1,1);
imshow(img);
title('Given Image');
total = ['Total Number of Pins: ',num2str(totalpins)];
text(-400,460,total,'FontWeight','bold');

total = ['Total Number of White/Transparent Pins: ',num2str(whitepins)];
text(-400,500,total,'FontWeight','bold');

text(-400,600,'Description of Colored Pins: ','FontWeight','bold');
y1spacing = 670;
y2spacing = 0;
for i = 1:length(ColorByFrequency)
   
    if ColorByFrequency(i) ~= 'White'
        total1 = [ ColorByFrequency(i)];
        text(-400,y1spacing,total1,'FontWeight','bold');
        
        total2 = [' : ',num2str(numOccurrences(i))];
        text(-100,y1spacing,total2,'FontWeight','bold');
        
        y1spacing = y1spacing +40;
    end
end


    
    
    
    
    
