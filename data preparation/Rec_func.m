function [] = Rec_func(word,recordnum)
%  word:      Word to be recorded.
%  recordnum: Number of records for each word.
%  e.g. Record 'Stop' for ten times types "Rec_func('Stop',10);" in command window. 
%  
%  Process:
%  (1) Create a folder named the word to be recorded at the path of the Rec_func.m file.
%      e.g. Create a folder named 'Stop' before start recording the word 'Stop'.
%  (2) After executing the function, command window will display "Ready to record"
%  (3) After two seconds command window will display "Start speaking.",
%      which means the record has started. 
%  (4) After two seconds command window will display "End of recording.",
%      which means a single record has ended. 
%  (5) After two seconds, the function will repeat step (2)~(4) for 'recordnum' times.
%  
    for i = 1:recordnum 
        Fs=44100;
        myVoice = audiorecorder(Fs,16,1);

        number  = sprintf('Ready to record: %d',i);
        disp(number);
        pause;  % Pause 2 seconds.
        myVoice.StartFcn = 'disp(''Start speaking.'')';
        myVoice.StopFcn = 'disp(''End of recording.'')';
        recordblocking(myVoice, 2); % Record 2 seconds.

        play(myVoice); % Replay speech being recorded.
        myRecording = getaudiodata(myVoice);

        saverecord = myRecording(10000:end);
        %plot(myRecording(10000:end));
        file  = sprintf('%s/%s%d.wav',word,word,i); % File path.    
        audiowrite(file,saverecord,Fs);

        pause(2);  % Pause 2 seconds.
    end
end

