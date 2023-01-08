[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-c66648af7eb3fe8bc4f294546bfd86ef473780cde1dea487d3c4ff354943c9ae.svg)](https://classroom.github.com/online_ide?assignment_repo_id=9231323&assignment_repo_type=AssignmentRepo)
# iw03
iOS assignment 3: Image Classification App.

作业 3-1 
  请基于模板工程(starter/HealthySnacks)，运用CoreML开发一个利用卷积神经网络分类snacks的App

功能要求如下：

1. 通过CreateML基于给定snacks数据集训练图像分类模型
2. 可针对拍照和相册中选择的图片利用训练好的模型进行snacks分类
3. 在屏幕上展示神经网络模型的分类结果

非功能需求如下：

1. 面对不属于数据集内给定snacks类别以外的图片，或模型本身把握不准的图片，给出“我不确定”的判断


作业 3-2
  请基于模板工程(starter/HealthySnacks)，运用CoreML开发一个利用卷积神经网络分类健康和非健康snacks的App

功能要求如下：

1. 改造snacks数据集，形成可供训练分类健康/非健康snacks模型的数据集
2. 通过CreateML基于改造的数据集训练图像分类模型
3. 可针对拍照和相册中选择的图片利用训练好的模型进行健康/非健康snacks的分类
4. 在屏幕上展示神经网络模型的分类结果

非功能需求如下：

1. 面对不属于数据集内给定snacks类别以外的图片，或模型本身把握不准的图片，给出“我不确定”的判断

作业 3-3 （无需提交结果，自学）

通过train_model.ipynb，学习PyTorch训练模型流程，以及如何将PyTorch模型转换为mlmodel的格式

