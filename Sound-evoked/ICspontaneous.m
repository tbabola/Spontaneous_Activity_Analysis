%%load data
%% Animal 1
soundFile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170825_P7_Animal1\Spontaneous\soundRecording.mat';
load(soundFile); %loads params, struct
ICfile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170825_P7_Animal1\Spontaneous\ICinfo16_dFoF.mat';
load(ICfile);
%% Animal 2
clear all;
soundFile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170906_P8_Animal2_\Spontaneous\170906_Snap25GC6s_P7_120db_1179_01_00.mat';
load(soundFile); %loads params, struct
ICfile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170906_P8_Animal2_\Spontaneous\ICinfo16_dFoF.mat';
load(ICfile);
%% Animal 3
clear all;
soundFile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170906_P8_Animal3\Spontaneous\170906_Snap25GC6s_P8_2_120dB_00.mat';
load(soundFile); %loads params, struct
ICfile = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\P7 Microphone Recordings and Tones\170906_P8_Animal3\Spontaneous\ICinfo16_dFoF.mat';
load(ICfile);

%% run brief analysis

%%before repeat code (Animal 1);
%soundR = data;
%params.fs =  1.9531e+05;

%%post repeat code (Animal 2,3)
 soundR = params.soundRecording;

[s,w,t] = spectrogram(soundR, 1024,500,1024,params.fs,'yaxis');
calls = max(abs(s(256:512,:))); %%looking for peaks in spectrogram to signify calls
callslog = smooth(calls > .75);

%movement from frame 2000 - 2350, discard this area
%ind = find(t > 200 & t < 235);
%callslog(ind) = 0; 
callInd = bwlabel(callslog);

traceBefore = 30;
traceAfter = 70;
chirpStart = [];
events = [];
figure;
for i=1:max(callInd)
    temp = find(callInd==i,1)
    chirpStart(i) = int32(round(t(temp)))
    if chirpStart(i) <= traceBefore
        skip = 1;
    else
        skip = 0;
    end
    if ~skip
        events(:,:,i) = ICsignal(chirpStart(i)-traceBefore:chirpStart(i)+traceAfter,1:2);
        plot(ICsignal(chirpStart(i)-traceBefore:chirpStart(i)+traceAfter,1:2));
     hold on;
    end
end

%% save data
Animal3 = struct();
Animal3.chirpStart = chirpStart;
Animal3.events = events;
%Animal1.spectrogram = s;
%Animal1.w = w;
%Animal1.s = s;
Animal3.ICsignal = ICsignal;
dname = fileparts(soundFile);
save([dname '\Animal1_spontaneous.mat'],'Animal3','-v7.3');

