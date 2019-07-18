[fn dname] = uigetfile();
img = loadTif([dname fn], 16);
[pathStr, name, ext] = fileparts([dname fn]);

%%
toneImg = {};
imgorig = img;
img = normalizeImg(img,10,1);
[LICmask, RICmask,ctxmask] = ROIselectionIC(img, [512 512]);
leftInd = find(LICmask);
rightInd = find(RICmask); 

%% load params
[fn2 dname2] = uigetfile(dname);
load([dname2 fn2]);
offset = 8;
starttone = (params.baselineDur - 1000)/100; %frames
toneISI = params.stimInt/100; %frames
toneDur = params.stimDur/100; %frames
timeBetweenStart = toneISI + toneDur;
before = 10; %frames before tone to analyze

for i = 1:params.repeats
    for j = 1:params.numFreqs
       startImg = offset + starttone + timeBetweenStart*(j-1) + params.numFreqs * timeBetweenStart * (i-1) - before
       endImg = startImg + timeBetweenStart + before;
       toneImg{i,j} = img(:,:,startImg:endImg);
    end

    %sort order based on random ordering of frequencies presented
    startInd = 1 + (i-1)*params.numFreqs;
    endInd = startInd + params.numFreqs - 1;
    [freqSort, order] = sort(params.freqs(startInd:endInd));
    toneImg(i,:) = toneImg(i,order);
end

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
        for k = 1:size(wimg,3)
            tempImg = wimg(:,:,k);
            LICsig(j,k,i) = mean(tempImg(leftInd));
            RICsig(j,k,i) = mean(tempImg(rightInd));
        end
    end
    avgToneImg{1,i} = mean(totalImg,4);
end
%%stop
%makes Brady-bunch style splaying of images versus frequency presented
concat = [];
for i = 1:4
   concat = [concat; avgToneImg{1,(4*(i-1)+1)} avgToneImg{1,(4*(i-1)+2)} avgToneImg{1,(4*(i-1)+3)} avgToneImg{1,(4*(i-1)+4)}];
end

%implay(normalizeImg(avgToneImg{1,2},10))

%% plot data
figure;
for i = 1:16
    subplot(1,16,i)
    wimg = avgToneImg{1,i};
    for j = 1:size(wimg,3)
        tempImg = wimg(:,:,j);
        avgLIC(i,j) = mean(tempImg(leftInd));
        avgRIC(i,j) = mean(tempImg(rightInd));
    end
    imagesc(mean(wimg(:,:,15:20),3));
    colormap(gfb);
    caxis([-0.1 0.75]);
end


%%single traces tones
copySigR = RICsig;
copySigL = LICsig;
for j = 1:size(RICsig,1)
    copySigR(j,:,:) = copySigR(j,:,:) - (j) * 0.4;
    copySigL(j,:,:) = copySigL(j,:,:) - (j) * 0.4;
end

lt_org = [255, 166 , 38]/255;
dk_org = [255, 120, 0]/255;
lt_blue = [50, 175, 242]/255;
dk_blue = [0, 13, 242]/255;
sorted = sort(params.freqs);
fig = figure;
for i = 1:16
    subplot(1,16,i);
    plot(copySigL(:,:,i)','Color',lt_org);
    hold on;
    plot(copySigR(:,:,i)','Color',lt_blue); 
    plot(avgLIC(i,:),'Color',lt_org,'LineWidth',2);
    plot(avgRIC(i,:),'Color',lt_blue,'LineWidth',2);
    ylim([-10*.4-.1 0.5]);
    xlim([0 60]);
    patch([10 10 20 20], [1 -6 -6 1],'k','EdgeColor','none','FaceAlpha',0.2);
    yticklabels('');
    title([sprintf('%0.3f',sorted(i*params.repeats)/1000) ' kHz']);
    axis off;
end

fig.Units = 'inches';
fig.Position = [2 2 12 8];