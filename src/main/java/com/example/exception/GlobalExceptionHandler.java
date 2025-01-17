package com.example.exception;

import com.example.common.CommonResult;
import com.example.controller.ApkController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;

/**
 * 统一异常处理类
 *
 * @author ThinkPad
 * @since 2025/1/17
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(ApkController.class);

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseBody
    public CommonResult<String> handleMaxSizeException(MaxUploadSizeExceededException e) {
        logger.error("文件超过最大限制: ", e);
        return CommonResult.failed("文件大小超过限制");
    }

    @ExceptionHandler(MultipartException.class)
    @ResponseBody
    public CommonResult<String> handleMultipartException(MultipartException e) {
        logger.error("文件上传错误: ", e);
        return CommonResult.failed(e.getMessage());
    }

    @ExceptionHandler(ApiException.class)
    @ResponseBody
    public CommonResult<String> handleApiException(ApiException e) {
        logger.error("API异常: ", e);
        return CommonResult.failed(e.getErrorCode(), e.getMessage());
    }
}