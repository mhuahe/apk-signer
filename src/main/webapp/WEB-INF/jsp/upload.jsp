<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>APK签名工具</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }

        .container {
            width: 90%;
            max-width: 600px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 30px;
            font-size: 28px;
        }

        .upload-section {
            text-align: center;
            margin-bottom: 25px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        .file-input-wrapper {
            width: 100%;
            max-width: 300px;
            margin-bottom: 5px;
        }

        .file-input {
            display: none;
        }

        .file-label {
            display: block;
            width: 100%;
            padding: 12px 24px;
            background: #3498db;
            color: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 16px;
            text-align: center;
        }

        .file-label:hover {
            background: #2980b9;
            transform: translateY(-1px);
        }

        .selected-file {
            margin-top: 8px;
            color: #666;
            font-size: 14px;
            word-break: break-all;
        }

        .buttons-container {
            display: flex;
            flex-direction: column;
            gap: 15px;
            align-items: center;
            width: 100%;
            max-width: 300px;
        }

        .btn {
            padding: 12px 28px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #2ecc71;
            color: white;
            width: 100%;
            text-align: center;
            display: inline-block;
            text-decoration: none;
        }

        .btn:hover {
            background: #27ae60;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .btn:disabled {
            background: #bdc3c7 !important;
            cursor: not-allowed;
            transform: none !important;
            box-shadow: none !important;
            opacity: 0.7;
        }

        #downloadBtn {
            display: none;
            background: #e67e22;
            margin-top: 10px;
        }

        #downloadBtn:hover {
            background: #d35400;
        }

        /* 进度条样式 */
        .progress-container {
            width: 100%;
            margin: 25px 0;
            display: none;
        }

        .progress-bar {
            width: 100%;
            height: 12px;
            background-color: #ecf0f1;
            border-radius: 6px;
            overflow: hidden;
            position: relative;
        }

        .progress {
            width: 0%;
            height: 100%;
            background: linear-gradient(45deg,
                #2ecc71 25%,
                #27ae60 25%,
                #27ae60 50%,
                #2ecc71 50%,
                #2ecc71 75%,
                #27ae60 75%);
            background-size: 20px 20px;
            animation: progressAnimation 1s linear infinite;
            transition: width 0.5s ease-in-out;
        }

        @keyframes progressAnimation {
            0% {
                background-position: 0 0;
            }
            100% {
                background-position: 20px 0;
            }
        }

        .progress-text {
            margin-top: 10px;
            font-size: 14px;
            color: #666;
            text-align: center;
        }

        .error .progress {
            background: #e74c3c;
        }

        /* 添加文件选择按钮的禁用状态样式 */
        .file-label.disabled {
            background: #bdc3c7;
            cursor: not-allowed;
            transform: none !important;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>APK签名工具</h2>
        <form id="uploadForm" class="upload-section">
            <div class="file-input-wrapper">
                <input type="file" name="apkFile" accept=".apk" required class="file-input" id="fileInput">
                <label for="fileInput" class="file-label">选择APK文件</label>
                <div class="selected-file" id="selectedFile">未选择文件</div>
            </div>
            <div class="buttons-container">
                <button type="submit" class="btn" id="submitBtn" disabled>上传并签名</button>
                <button type="button" id="downloadBtn" class="btn">下载签名后的APK</button>
            </div>
        </form>
        
        <!-- 进度条 -->
        <div class="progress-container" id="progressContainer">
            <div class="progress-bar">
                <div class="progress" id="progressBar"></div>
            </div>
            <div class="progress-text" id="progressText">准备上传...</div>
        </div>
    </div>

    <script type="text/javascript">
        //<![CDATA[
        // 获取当前应用的上下文路径
        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/",2));
        
        // 获取按钮元素
        var submitBtn = document.getElementById('submitBtn');
        var fileInput = document.getElementById('fileInput');
        var selectedFile = document.getElementById('selectedFile');
        
        // 文件选择处理
        fileInput.onchange = function(e) {
            var file = e.target.files[0];
            if (file) {
                // 有文件被选择
                selectedFile.textContent = file.name;
                submitBtn.disabled = false;  // 启用上传按钮
                
                // 检查文件类型
                if (!file.name.toLowerCase().endsWith('.apk')) {
                    selectedFile.textContent = '请选择APK文件';
                    submitBtn.disabled = true;
                    fileInput.value = '';  // 清空文件选择
                    alert('请选择正确的APK文件！');
                    return;
                }
                
                // 检查文件大小（如果需要）
                if (file.size > 100 * 1024 * 1024) { // 100MB限制
                    selectedFile.textContent = '文件太大，请选择小于100MB的文件';
                    submitBtn.disabled = true;
                    fileInput.value = '';  // 清空文件选择
                    alert('文件大小超过限制！');
                    return;
                }
            } else {
                // 没有文件被选择
                selectedFile.textContent = '未选择文件';
                submitBtn.disabled = true;  // 禁用上传按钮
            }
        };

        // 表单提交处理
        document.getElementById('uploadForm').onsubmit = function(e) {
            e.preventDefault();
            
            var formData = new FormData(this);
            var progressBar = document.getElementById('progressBar');
            var progressText = document.getElementById('progressText');
            var progressContainer = document.getElementById('progressContainer');
            var downloadBtn = document.getElementById('downloadBtn');
            
            // 显示进度条并禁用所有操作
            progressContainer.style.display = 'block';
            progressBar.style.width = '0%';
            downloadBtn.style.display = 'none';
            submitBtn.disabled = true;
            fileInput.disabled = true;
            
            // 定义阶段
            var stages = {
                PREPARING: { progress: 0, text: '准备上传...' },
                UPLOADING: { progress: 10, text: '正在上传APK文件' },
                UPLOADED: { progress: 60, text: '上传完成，准备签名' },
                SIGNING: { progress: 70, text: '正在进行APK签名' },
                VERIFYING: { progress: 90, text: '正在验证签名' },
                COMPLETED: { progress: 100, text: '签名完成！' },
                FAILED: { text: '处理失败' }
            };
            
            // 更新阶段
            function updateStage(stage, actualProgress) {
                var stageInfo = stages[stage];
                var progress = actualProgress || stageInfo.progress;
                progressBar.style.width = progress + '%';
                progressText.textContent = stageInfo.text;
                if (progress) {
                    progressText.textContent += ' (' + parseInt(progress) + '%)';
                }
            }
            
            // 发送请求
            var xhr = new XMLHttpRequest();
            xhr.open('POST', contextPath + '/upload', true);
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            
            // 开始上传
            xhr.upload.onloadstart = function() {
                updateStage('PREPARING');
            };
            
            // 上传进度
            xhr.upload.onprogress = function(e) {
                if (e.lengthComputable) {
                    var uploadProgress = (e.loaded / e.total) * 50 + 10;
                    updateStage('UPLOADING', uploadProgress);
                }
            };
            
            // 上传完成
            xhr.upload.onload = function() {
                updateStage('UPLOADED');
            };
            
            // 完成处理
            xhr.onload = function() {
                fileInput.disabled = false;
                if (xhr.status === 200) {
                    var result = xhr.responseText;
                    if(result.startsWith('success')) {
                        updateStage('SIGNING');
                        setTimeout(function() {
                            updateStage('VERIFYING');
                            setTimeout(function() {
                                updateStage('COMPLETED');
                                downloadBtn.style.display = 'inline-block';
                            }, 500);
                        }, 500);
                    } else {
                        submitBtn.disabled = !fileInput.files.length; // 根据是否有文件决定按钮状态
                        var errorMsg = result.replace('error: ', '').trim();
                        updateStage('FAILED');
                        progressBar.style.background = '#f44336';
                        alert('处理失败：\n' + decodeURIComponent(errorMsg));
                    }
                } else {
                    submitBtn.disabled = !fileInput.files.length; // 根据是否有文件决定按钮状态
                    updateStage('FAILED');
                    progressBar.style.background = '#f44336';
                    alert('上传失败：服务器错误');
                }
            };
            
            // 错误处理
            xhr.onerror = function() {
                submitBtn.disabled = !fileInput.files.length;
                fileInput.disabled = false;
                updateStage('FAILED');
                progressBar.style.background = '#f44336';
                alert('上传失败：网络错误');
            };
            
            // 超时处理
            xhr.timeout = 300000; // 5分钟超时
            xhr.ontimeout = function() {
                submitBtn.disabled = !fileInput.files.length;
                fileInput.disabled = false;
                updateStage('FAILED');
                progressBar.style.background = '#f44336';
                alert('上传超时，请重试');
            };
            
            // 发送数据
            xhr.send(formData);
        };

        // 修改下载按钮的链接
        document.getElementById('downloadBtn').onclick = function() {
            window.location.href = contextPath + '/download';
            return false;
        };
        //]]>
    </script>
</body>
</html> 