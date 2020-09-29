# Speech-Recognition-LPC-SVM
## A Lightweight speech recognition algorithm using LPC and SVM

This project aims at developing a lightweight speech recognition algorithm for Multimodal Tongue Drive System (mTDS) [1], an assistive technology for people with tetraplegia that uses speech recognition (SR), tongue and head motion to control devices such as a wheelchair or a computer.

[1] Sahadat, M. N., Sebkhi, N., Anderson, D., & Ghovanloo, M. (2018). Optimization of tongue gesture processing algorithm for standalone multimodal tongue drive system. IEEE Sensors Journal, 19(7), 2704-2712.

### train folder:
Contains codes for recording, pre-processing, and generating LPC coefficients of speech signals.
The generated LPC coefficients is saved in the train_final subfolder, those files are written with the LIBSVM data format.

### test folder:
Contains codes for pre-processing and generating LPC coefficients of speech signals.
The SR_test.m file contains the pipeline for testing the trained model, from recording a speech signal to making a prediction.
The trained model is saved in the model subfolder, and other subfolders contain the LPC data with LIBSVM format.

### libsvm_3.23:
Contains the codes of LIBSVM library, training script, data, and trained model are saved in the matlab subfolder.
The grid.py in the tool subfolder can be used to perform cross-validation and select optimal parameters.

### doc:
Contains the final report, presentation, and a note of the conducted experiment.
