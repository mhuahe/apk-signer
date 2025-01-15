package com.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import javax.annotation.PostConstruct;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.BufferedReader;
import java.io.InputStreamReader;

@Controller
public class ApkController {
    
    private static final Logger logger = LoggerFactory.getLogger(ApkController.class);
    @Value("${app.upload.dir.windows}")
    private String windowsUploadDir;
    
    @Value("${app.upload.dir.linux}")
    private String linuxUploadDir;
    
    @Value("${app.sign.script.windows}")
    private String windowsSignScript;
    
    @Value("${app.sign.script.linux}")
    private String linuxSignScript;
    
    private String uploadDir;
    private String signScript;
    private static final String SIGNED_APK_NAME = "signed.apk";
    private static final String ORIGINAL_APK_NAME = "original.apk";
    
    @PostConstruct
    private void init() {
        boolean isWindows = isWindows();
        
        // 根据操作系统选择配置
        this.uploadDir = normalizePath(isWindows ? windowsUploadDir : linuxUploadDir);
        this.signScript = normalizePath(isWindows ? windowsSignScript : linuxSignScript);
        
        createUploadDir();
        checkSignScript();
        
        // 在Linux环境下确保脚本使用正确的换行符
        if (!isWindows) {
            try {
                convertScriptToUnix();
            } catch (IOException e) {
                logger.error("转换脚本换行符失败", e);
            }
        }
        
        logger.info("当前操作系统: {}", System.getProperty("os.name"));
        logger.info("上传目录已初始化: {}", uploadDir);
        logger.info("签名脚本已配置: {}", signScript);
    }
    
    private String normalizePath(String path) {
        return path.replace('\\', File.separatorChar).replace('/', File.separatorChar);
    }
    
    private void checkSignScript() {
        File script = new File(signScript);
        if (!script.exists()) {
            logger.error("签名脚本不存在: {}", signScript);
            throw new RuntimeException("签名脚本不存在: " + signScript);
        }
        if (!script.canExecute()) {
            // 在Linux下尝试添加执行权限
            if (!isWindows()) {
                boolean b = script.setExecutable(true);
                logger.info("在Linux下尝试添加执行权限结果: {}", b);
            }
            if (!script.canExecute()) {
                logger.warn("签名脚本可能没有执行权限: {}", signScript);
            }
        }
    }
    
    private void createUploadDir() {
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            if (created) {
                logger.info("创建上传目录成功: {}", uploadDir);
            } else {
                logger.error("创建上传目录失败: {}", uploadDir);
            }
        }
    }

    private Boolean isWindows() {
        return System.getProperty("os.name").toLowerCase().contains("windows");
    }
    
    @GetMapping("/")
    public String index() {
        return "upload";
    }
    
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public String uploadApk(@RequestParam("apkFile") MultipartFile file) {
        logger.info("收到上传请求");
        try {
            if (file == null || file.isEmpty()) {
                logger.warn("文件为空");
                return "error: 未选择文件或文件为空";
            }
            
            logger.info("文件信息 - 名称: {}, 大小: {}bytes", file.getOriginalFilename(), file.getSize());
            
            // 检查文件大小
            if (file.getSize() > 100 * 1024 * 1024) { // 100MB
                return "error: 文件大小超过限制";
            }
            
            // 检查文件类型
            String fileName = file.getOriginalFilename();
            if (fileName == null || !fileName.toLowerCase().endsWith(".apk")) {
                return "error: 请选择APK文件";
            }
            
            // 检查上传目录权限
            File dir = new File(uploadDir);
            logger.info("上传目录权限检查 - 存在: {}, 可读: {}, 可写: {}, 可执行: {}", 
                dir.exists(), dir.canRead(), dir.canWrite(), dir.canExecute());

            if (!dir.canWrite()) {
                String error = String.format("上传目录没有写入权限: %s", uploadDir);
                logger.error(error);
                return "error: " + error;
            }

            createUploadDir();
            
            File originalApkFile = new File(uploadDir, ORIGINAL_APK_NAME);
            logger.info("准备保存文件 - 路径: {}, 大小: {}bytes", 
                originalApkFile.getAbsolutePath(), file.getSize());
            
            try {
                file.transferTo(originalApkFile);
                logger.info("文件保存成功 - 文件存在: {}, 大小: {}bytes", 
                    originalApkFile.exists(), originalApkFile.length());
            } catch (IOException e) {
                String error = String.format("保存文件失败: %s, 错误: %s", 
                    originalApkFile.getAbsolutePath(), e.getMessage());
                logger.error(error, e);
                return "error: " + error;
            }
            
            // 检查脚本权限
            File scriptFile = new File(signScript);
            logger.info("脚本权限检查 - 存在: {}, 可读: {}, 可写: {}, 可执行: {}", 
                scriptFile.exists(), scriptFile.canRead(), scriptFile.canWrite(), scriptFile.canExecute());

            if (!scriptFile.canExecute()) {
                String error = String.format("签名脚本没有执行权限: %s", signScript);
                logger.error(error);
                return "error: " + error;
            }

            // 根据操作系统选择不同的命令
            ProcessBuilder processBuilder;
            if (isWindows()) {
                processBuilder = new ProcessBuilder("cmd", "/c", signScript, uploadDir);
            } else {
                processBuilder = new ProcessBuilder("/bin/bash", signScript, uploadDir);
                logger.info("Linux环境检查 - bash是否存在: {}", new File("/bin/bash").exists());
            }
            
            processBuilder.directory(new File(uploadDir));
            processBuilder.redirectErrorStream(true);
            
            logger.info("准备执行命令 - 工作目录: {}, 命令: {} {}", 
                processBuilder.directory().getAbsolutePath(), signScript, uploadDir);
            
            Process process = processBuilder.start();
            
            // 读取命令输出
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            
            // 等待进程完成并获取退出码
            int exitCode = process.waitFor();
            String outputStr = output.toString();
            logger.info("命令输出: \n{}", outputStr);
            logger.info("签名脚本执行完成，退出码: {}", exitCode);
            
            // 检查签名后的文件是否存在
            File signedFile = new File(uploadDir, SIGNED_APK_NAME);
            if (signedFile.exists() && signedFile.length() > 0) {
                logger.info("签名成功，生成文件: {}", signedFile.getAbsolutePath());
                return "success";
            } else {
                logger.error("签名后的文件不存在或大小为0: {}", signedFile.getAbsolutePath());
                return "error: " + outputStr;
            }
            
        } catch (Exception e) {
            String error = String.format("处理APK文件时发生错误: %s", e.getMessage());
            logger.error(error, e);
            return "error: " + error;
        }
    }
    
    @GetMapping("/download")
    public ResponseEntity<Resource> downloadSignedApk() {
        try {
            File signedFile = new File(uploadDir, SIGNED_APK_NAME);
            Resource resource = new UrlResource(signedFile.toURI());
            
            if (resource.exists()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_OCTET_STREAM)
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + SIGNED_APK_NAME + "\"")
                        .body(resource);
            } else {
                logger.error("下载文件不存在: {}", signedFile.getAbsolutePath());
                return ResponseEntity.notFound().build();
            }
        } catch (IOException e) {
            logger.error("下载文件时发生错误", e);
            return ResponseEntity.notFound().build();
        }
    }

    private void convertScriptToUnix() throws IOException {
        File scriptFile = new File(signScript);
        if (!scriptFile.exists()) {
            return;
        }
        
        // 读取脚本内容
        String content = new String(java.nio.file.Files.readAllBytes(scriptFile.toPath()), StandardCharsets.UTF_8);
        // 替换所有 CRLF 为 LF
        content = content.replace("\r\n", "\n");
        // 写回文件
        java.nio.file.Files.write(scriptFile.toPath(), content.getBytes(StandardCharsets.UTF_8));
        
        // 确保有执行权限
        scriptFile.setExecutable(true);
        logger.info("脚本文件已转换为Unix格式");
    }
} 