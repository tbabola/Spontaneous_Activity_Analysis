%[fname, dname] = uigetfile('M:\Bergles Lab Data\Projects\In vivo imaging\*.tif','Multiselect','on');
[fname, dname] = uigetfile('M:\Bergles Lab Data\Projects\In vivo imaging\*.tif','Multiselect','on');

[~,~,ext] = fileparts([dname, fname]);

%%tif performance 
if strcmp(ext,'.tif') 
    tic;
    X = loadTif([dname fname],16);
    toc;
elseif strcmp(ext,'.czi')
    tic;
    img = bfLoadTif([dname fname]);
    img = imrotate(img,180);
    toc;
else
    disp('Invalid image format.')
end

tr=squeeze(mean(mean(img)));

%%
toneImg = {};
imgorig = img;
img = normalizeImg(img,10,1);
% [LICmask, RICmask,ctxmask] = ROIselectionIC(img, [512 512]);
% leftInd = find(LICmask);
% rightInd = find(RICmask); 
%%
offset = 0;
k=0;
i=1;
while k == 0
    if tr(i)>1000
        offset=i-1;
        k=1;
    end
    i = i+1;
end

%% load params
[fn2 dname2] = uigetfile(dname);
load([dname2 fn2]);
starttone = (params.baselineDur)/100; %frames
toneISI = params.stimInt/100; %frames
toneDur = params.stimDur/100; %frames
timeBetweenStart = toneISI + toneDur;
before = 10; %frames before tone to analyze
[freqSort, order] = sort(params.freqs);
toneImg = {};
count = 1;
temp = [];
for j = order'
  j;
  startImg = offset + starttone + timeBetweenStart*(j-1) - before;
  endImg = startImg + timeBetweenStart + before;
  toneImg{count} = img(:,:,startImg:endImg);
  temp(j,:) = [j startImg endImg count params.freqs(j)];
  count = count + 1;
  
end
toneImg = reshape(toneImg, params.repeats, params.numFreqs);

avgToneImg = {};
totalImg = [];
[mm,nn,tt] = size(toneImg{1,1});
LICsig = [];
RICsig = [];
for i = 1:params.numFreqs
    totalImg = zeros(mm,nn,tt,params.repeats);
    for j = 1:params.repeats
        wimg = toneImg{j,i};
        totalImg(:,:,:,j) = wimg;
%         for k = 1:size(wimg,3)
%             tempImg = wimg(:,:,k);
% %             LICsig(j,k,i) = mean(tempImg(leftInd));
% %             RICsig(j,k,i) = mean(tempImg(rightInd));
%         end
    end
    avgToneImg{1,i} = mean(totalImg,4);
end
%%stop
%makes Brady-bunch style splaying of images versus frequency presented
concat = [];
for i = 1:3
   concat = [concat; avgToneImg{1,(4*(i-1)+1)} avgToneImg{1,(4*(i-1)+2)} avgToneImg{1,(4*(i-1)+3)} avgToneImg{1,(4*(i-1)+4)}];
end

%implay(normalizeImg(avgToneImg{1,2},10))
%%
avgTones = [];
for i = 1:16
    avgTones(:,:,:,i) = avgToneImg{1,i};
end

%%

%%[m,n,T,t] = size(avgTones);
r = avgTones(:,:,5:40,1);
g = avgTones(:,:,5:40,4);
b = avgTones(:,:,5:40,12);
rgb = [];
rgb(:,:,1,:) = r;
rgb(:,:,2,:) = g;
rgb(:,:,3,:) = b;

implay(rgb);
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('test.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

% for i = 1:16
%     tifwrite(:,:,i) = avgTones(:,:,12,i);
% end

%%
test = concat;
r = test(1:512,1:512);
g = test(513:1024,1025:1536);
b = test(1025:1536,1025:1536);
rgb = [];
rgb(:,:,1) = r*7;
rgb(:,:,2) = g*7;
rgb(:,:,3) = b*7;

K = imadjust(rgb,[0.3 0.9],[]); % I is double
figure; imshow(imgaussfilt(K,2))
%figure; imagesc(rgb);

%% plot data
figure;
for i = 1:16
    subplot(4,4,i)
    wimg = avgToneImg{1,i};
%     for j = 1:size(wimg,3)
%         tempImg = wimg(:,:,j);
% %         avgLIC(i,j) = mean(tempImg(leftInd));
% %         avgRIC(i,j) = mean(tempImg(rightInd));
%     end
    imagesc(mean(wimg(:,:,10:30),3));
    colormap(gray);
    caxis([-0.1 .3]);
end

% 
% %%single traces tones
% copySigR = RICsig;
% copySigL = LICsig;
% for j = 1:size(RICsig,1)
%     copySigR(j,:,:) = copySigR(j,:,:) - (j) * 0.4;
%     copySigL(j,:,:) = copySigL(j,:,:) - (j) * 0.4;
% end
% 
% lt_org = [255, 166 , 38]/255;
% dk_org = [255, 120, 0]/255;
% lt_blue = [50, 175, 242]/255;
% dk_blue = [0, 13, 242]/255;
% sorted = sort(params.freqs);
% fig = figure;
% for i = 1:16
%     subplot(1,16,i);
%     plot(copySigL(:,:,i)','Color',lt_org);
%     hold on;
%     plot(copySigR(:,:,i)','Color',lt_blue); 
%     plot(avgLIC(i,:),'Color',lt_org,'LineWidth',2);
%     plot(avgRIC(i,:),'Color',lt_blue,'LineWidth',2);
%     ylim([-10*.4-.1 0.5]);
%     xlim([0 60]);
%     patch([10 10 20 20], [1 -6 -6 1],'k','EdgeColor','none','FaceAlpha',0.2);
%     yticklabels('');
%     title([sprintf('%0.3f',sorted(i*params.repeats)/1000) ' kHz']);
%     axis off;
% end
% 
% fig.Units = 'inches';
% fig.Position = [2 2 12 8];