clear;
load('model/model_K12.mat');
[label2, inst2] = libsvmread('test_label/K12F23/test1_MZthd_less1.txt');
[predict_label, accuracy, dec_values] = svmpredict(label2,inst2, model);