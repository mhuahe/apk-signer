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
    private String uploadDir;
    private String signScript;
    private static final String SIGNED_APK_NAME = "signed.apk";
    private static final String ORIGINAL_APK_NAME = "original.apk";
    
    @Value("${app.upload.dir}")
    private String configuredUploadDir;
    
    @Value("${app.sign.script}")
    private String configuredSignScript;
    
    @PostConstruct
    private void init() {
        this.uploadDir = configuredUploadDir;
        this.signScript = configuredSignScript;
        createUploadDir();
        checkSignScript();
        logger.info("上传目录已初始化: {}", uploadDir);
        logger.info("签名脚本已配置: {}", signScript);
    }
    
    private void checkSignScript() {
        File script = new File(signScript);
        if (!script.exists()) {
            logger.error("签名脚本不存在: {}", signScript);
            throw new RuntimeException("签名脚本不存在: " + signScript);
        }
        if (!script.canExecute()) {
            logger.warn("签名脚本可能没有执行权限: {}", signScript);
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
    
    @GetMapping("/")
    public String index() {
        return "upload";
    }
    
    @PostMapping("/upload")
    @ResponseBody
    public String uploadApk(@RequestParam("apkFile") MultipartFile file) {
        try {
            createUploadDir();
            
            File originalApkFile = new File(uploadDir, ORIGINAL_APK_NAME);
            logger.info("正在保存文件到: {}", originalApkFile.getAbsolutePath());
            file.transferTo(originalApkFile);
            
            // 使用配置的脚本路径
            ProcessBuilder processBuilder = new ProcessBuilder("cmd", "/c", signScript, uploadDir);
            processBuilder.directory(new File(uploadDir)); // 直接在上传目录中执行
            processBuilder.redirectErrorStream(true);
            
            logger.info("工作目录: {}", processBuilder.directory().getAbsolutePath());
            logger.info("执行命令: {} {}", signScript, uploadDir);
            
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
            logger.error("处理APK文件时发生错误", e);
            return "error: " + e.getMessage();
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
} 