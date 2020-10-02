# Speech-Recognition-LPC-SVM
## A Lightweight speech recognition algorithm using LPC and SVM

This project aims at developing a lightweight speech recognition algorithm for Multimodal Tongue Drive System (mTDS) [1], an assistive technology for people with tetraplegia that uses speech recognition (SR), tongue and head motion to control devices such as a wheelchair or a computer.

[1] Sahadat, M. N., Sebkhi, N., Anderson, D., & Ghovanloo, M. (2018). Optimization of tongue gesture processing algorithm for standalone multimodal tongue drive system. IEEE Sensors Journal, 19(7), 2704-2712.

#### data preparation:
Contains codes for recording human speech (`Rec_func.m`), data pre-processing, and generating LPC coefficients of speech signals (`LPC_data_proc.m`).
The generated LPC coefficients is saved in `train_final/`, those files are written with the LIBSVM data format.

#### libsvm_3.23:
Contains the codes of [LIBSVM library](http://www.csie.ntu.edu.tw/~cjlin/libsvm). More instructions can be found in the readme file in the folder. Training script (`train_subset.m`), data (`train_final/`), and trained model (`model_final/`) are saved in the matlab subfolder.
The grid.py in `tool/` can be used to perform cross-validation and select optimal parameters.

#### test:
Contains codes for pre-processing and generating LPC coefficients of testing speech signals.
The SR_test.m file contains the pipeline for testing the trained model, from recording a speech signal to making a prediction.
The trained model is saved in the model subfolder, and other subfolders contain the testing LPC data with LIBSVM format.

#### doc:
Contains the final [report](https://github.com/yahsieh37/Speech-Recognition-LPC-SVM/blob/master/doc/Report.pdf) and presentation.
