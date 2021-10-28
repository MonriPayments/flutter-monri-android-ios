package com.example.MonriPayments_example.monri_http_helper;

@FunctionalInterface
public interface Consumer<T> {
    void accept(T t);
}
