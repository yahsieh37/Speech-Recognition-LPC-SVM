function [] = train_subset(tr,te)
tr_file = sprintf('train/train_K8F21/tr%d',tr);
[label, inst] = libsvmread(tr_file);
model = svmtrain(label, inst, '-c 32 -g 0.002');
te_file = sprintf('train/train_K8F21/te%d',te);
[label2, inst2] = libsvmread(te_file);
[predict_label, accuracy, dec_values] = svmpredict(label2,inst2, model);
disp('Predict');
disp(predict_label);
disp('Label');
disp(label2);
end
