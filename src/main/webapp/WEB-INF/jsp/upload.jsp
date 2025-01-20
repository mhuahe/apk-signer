<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
            gap: 12px;
        }

        .file-input-wrapper {
            width: 100%;
            max-width: 300px;
            margin-bottom: 0;
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
            margin-bottom: 4px;
        }

        .buttons-container {
            display: flex;
            flex-direction: column;
            gap: 12px;
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

        .keystore-wrapper {
            width: 100%;
            max-width: 300px;
            margin: 0;
        }

        .keystore-select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background-color: white;
            cursor: pointer;
            appearance: none;
            -webkit-appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23666' d='M6 8.825L1.175 4 2.238 2.938 6 6.7l3.763-3.763L10.825 4z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            padding-right: 36px;
        }

        .keystore-select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }

        .keystore-select:hover {
            border-color: #3498db;
        }

        .keystore-label {
            display: block;
            margin-bottom: 6px;
            color: #666;
            font-size: 14px;
            font-weight: 500;
        }

        /* 添加分隔线 */
        .divider {
            width: 100%;
            max-width: 300px;
            height: 1px;
            background: #eee;
            margin: 12px auto;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>APK签名工具</h2>
    <form id="uploadForm" class="upload-section">
        <div class="file-input-wrapper">
            <label class="keystore-label">APK文件</label>
            <input type="file" name="apkFile" accept=".apk" required class="file-input" id="fileInput">
            <label for="fileInput" class="file-label">选择APK文件</label>
            <div class="selected-file" id="selectedFile">未选择文件</div>
        </div>

        <div class="divider"></div>

        <div class="keystore-wrapper">
            <label class="keystore-label">签名证书</label>
            <select id="keystoreSelect" class="keystore-select" required>
                <option value="">请选择签名证书</option>
            </select>
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
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2));

    // 获取按钮元素
    const submitBtn = document.getElementById('submitBtn');
    const fileInput = document.getElementById('fileInput');
    const selectedFile = document.getElementById('selectedFile');
    const keystoreSelect = document.getElementById('keystoreSelect');

    // 文件选择处理
    fileInput.onchange = function (e) {
        const file = e.target.files[0];
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
            }
        } else {
            // 没有文件被选择
            selectedFile.textContent = '未选择文件';
            submitBtn.disabled = true;  // 禁用上传按钮
        }
        updateSubmitButtonState();
    };

    // 添加一个函数来处理文件名显示
    function formatFileName(fileName, maxLength = 20) {
        if (fileName.length <= maxLength) {
            return fileName;
        }
        const ext = fileName.lastIndexOf('.') > -1 
            ? fileName.substring(fileName.lastIndexOf('.')) 
            : '';
        const nameWithoutExt = fileName.substring(0, fileName.length - ext.length);
        const truncatedName = nameWithoutExt.substring(0, maxLength - 3 - ext.length) + '...';
        return truncatedName + ext;
    }

    // 修改加载签名文件列表的函数
    function loadKeystores() {
        fetch(contextPath + '/keystores')
            .then(response => response.json())
            .then(result => {
                const select = document.getElementById('keystoreSelect');
                select.innerHTML = '';
                
                if (result.code === 200 && Array.isArray(result.data)) {
                    if (result.data.length > 0) {
                        // 添加签名文件选项
                        result.data.forEach((keystore, index) => {
                            const option = document.createElement('option');
                            option.value = keystore;
                            // 格式化显示名称
                            option.textContent = formatFileName(keystore);
                            // 添加完整名称作为title，鼠标悬停时显示
                            option.title = keystore;
                            select.appendChild(option);
                        });
                        // 默认选中第一个选项
                        select.selectedIndex = 0;
                    } else {
                        const option = document.createElement('option');
                        option.value = '';
                        option.textContent = '未找到签名证书';
                        select.appendChild(option);
                    }
                } else {
                    const option = document.createElement('option');
                    option.value = '';
                    option.textContent = '加载签名证书失败';
                    select.appendChild(option);
                }
                select.dispatchEvent(new Event('change'));
            })
            .catch(error => {
                const select = document.getElementById('keystoreSelect');
                select.innerHTML = '<option value="">加载失败，请刷新重试</option>';
                select.dispatchEvent(new Event('change'));
            });
    }

    // 页面加载时获取签名文件列表
    document.addEventListener('DOMContentLoaded', loadKeystores);

    // 表单提交处理
    document.getElementById('uploadForm').onsubmit = function (e) {
        e.preventDefault();
        
        if (!keystoreSelect.value) {
            alert('请选择签名证书');
            return;
        }
        
        const formData = new FormData(this);
        formData.append('keystore', keystoreSelect.value);
        const progressBar = document.getElementById('progressBar');
        const progressText = document.getElementById('progressText');
        const progressContainer = document.getElementById('progressContainer');
        const downloadBtn = document.getElementById('downloadBtn');

        // 显示进度条并禁用所有操作
        progressContainer.style.display = 'block';
        progressBar.style.width = '0%';
        downloadBtn.style.display = 'none';
        submitBtn.disabled = true;
        fileInput.disabled = true;

        // 定义阶段
        const stages = {
            PREPARING: {progress: 0, text: '准备上传...'},
            UPLOADING: {progress: 10, text: '正在上传APK文件'},
            UPLOADED: {progress: 60, text: '上传完成，准备签名'},
            SIGNING: {progress: 70, text: '正在进行APK签名'},
            VERIFYING: {progress: 90, text: '正在验证签名'},
            COMPLETED: {progress: 100, text: '签名完成！'},
            FAILED: {text: '处理失败'}
        };

        // 更新阶段
        function updateStage(stage, actualProgress) {
            const stageInfo = stages[stage];
            const progress = actualProgress || stageInfo.progress;
            progressBar.style.width = progress + '%';
            progressText.textContent = stageInfo.text;
            if (progress) {
                progressText.textContent += ' (' + parseInt(progress) + '%)';
            }
        }

        // 解析响应
        function parseResponse(responseText) {
            try {
                // 尝试解析 JSON
                const {code, message, data} = JSON.parse(responseText);
                return {code, message, data};
            } catch (error) {
                // 不是 JSON 或解析失败
                console.error('响应解析失败：', error);
                return {
                    code: -1,
                    message: '响应格式错误',
                    data: responseText // 保留原始响应
                };
            }
        }

        // 发送请求
        const xhr = new XMLHttpRequest();
        xhr.open('POST', contextPath + '/upload',);
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

        // 开始上传
        xhr.upload.onloadstart = function () {
            updateStage('PREPARING');
        };

        // 上传进度
        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) {
                const uploadProgress = (e.loaded / e.total) * 50 + 10;
                updateStage('UPLOADING', uploadProgress);
            }
        };

        // 上传完成
        xhr.upload.onload = function () {
            updateStage('UPLOADED');
        };

        // 完成处理
        xhr.onload = function () {
            fileInput.disabled = false;
            const {code, message} = parseResponse(xhr.responseText);
            if (code === 200) {
                updateStage('SIGNING');
                setTimeout(function () {
                    updateStage('VERIFYING');
                    setTimeout(function () {
                        updateStage('COMPLETED');
                        downloadBtn.style.display = 'inline-block';
                    }, 500);
                }, 500);
            } else {
                submitBtn.disabled = !fileInput.files.length; // 根据是否有文件决定按钮状态
                updateStage('FAILED');
                progressBar.style.background = '#f44336';
                alert('上传失败：\n' + decodeURIComponent(message));
            }
        };

        // 错误处理
        xhr.onerror = function () {
            submitBtn.disabled = !fileInput.files.length;
            fileInput.disabled = false;
            updateStage('FAILED');
            progressBar.style.background = '#f44336';
            alert('上传失败：网络错误');
        };

        // 超时处理
        xhr.timeout = 300000; // 5分钟超时
        xhr.ontimeout = function () {
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
    document.getElementById('downloadBtn').onclick = function () {
        window.location.href = contextPath + '/download';
        return false;
    };

    // 修改上传按钮状态控制
    function updateSubmitButtonState() {
        const hasFile = fileInput.files.length > 0;
        const hasKeystore = keystoreSelect.value !== '';
        submitBtn.disabled = !(hasFile && hasKeystore);
    }

    keystoreSelect.onchange = updateSubmitButtonState;
    //]]>
</script>
</body>
</html> 