package com.example.MonriPayments_example.monri_http_helper;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MonriHttpHelper {

    ExecutorService executor = Executors.newSingleThreadExecutor();
    Handler handler = new Handler(Looper.getMainLooper());

    public MonriHttpHelper() {
    }

    private static HttpURLConnection createHttpURLConnection(final String endpoint,
                                                      final MonriHttpMethod monriHttpMethod,
                                                      final Map<String, String> headers) throws IOException {
        URL url = new URL(endpoint);
        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
        urlConnection.setRequestMethod(monriHttpMethod.getValue());

        switch (monriHttpMethod) {
            case GET:
                break;
            case POST:
                urlConnection.setDoInput(true);//Allow Inputs
                urlConnection.setDoOutput(true);//Allow Outputs
                urlConnection.setChunkedStreamingMode(0);
                urlConnection.setUseCaches(false);//Don't use a cached Copy
                break;
            default:
        }

        for (String key : headers.keySet()) {
            urlConnection.setRequestProperty(key, headers.get(key));
        }

        return urlConnection;

    }

    private static final String BASE_URL = "https://ipgtest.monri.com";
    private static final String MERCHANT_KEY = "key-e428ba618ebc232a595d0851398b8a5d"; // Replace with your actual key
    private static final String AUTHENTICITY_TOKEN = "c6301017117302601b823874972a97acce96f2df"; // Replace with your token

    //todo error consumer...
    public static AsyncTask<Void, Void, String> createPaymentSession(Consumer<String> consumer) {
        return new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(final Void... voids) {
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("amount", 100);
                    // Match Swift format with hyphen instead of underscore
                    jsonObject.put("order_number", "order-" + System.currentTimeMillis() / 1000);
                    jsonObject.put("currency", "EUR");
                    jsonObject.put("transaction_type", "purchase");
                    jsonObject.put("order_info", "Create payment session order info");
                    jsonObject.put("scenario", "charge");

                    // Print full payload for comparison with Swift
                    String bodyAsString = jsonObject.toString();
                    System.out.println("Full JSON payload: " + bodyAsString);

                    long timestamp = System.currentTimeMillis() / 1000;

                    // For debugging - print all components used in digest
                    System.out.println("MERCHANT_KEY: " + MERCHANT_KEY);
                    System.out.println("timestamp: " + timestamp);
                    System.out.println("AUTHENTICITY_TOKEN: " + AUTHENTICITY_TOKEN);
                    System.out.println("bodyAsString: " + bodyAsString);

                    String digest = generateDigest(MERCHANT_KEY, timestamp, AUTHENTICITY_TOKEN, bodyAsString);
                    System.out.println("Generated digest: " + digest);
                    System.out.println("SHA-512: " + sha512("da"));

                    String authorization = "WP3-v2 " + AUTHENTICITY_TOKEN + " " + timestamp + " " + digest;
                    System.out.println("Authorization header: " + authorization);

                    HashMap<String, String> headers = new HashMap<>();
                    headers.put("Content-Type", "application/json");
                    headers.put("Authorization", authorization);

                    final HttpURLConnection urlConnection =
                            createHttpURLConnection(
                                    BASE_URL + "/v2/payment/new",
                                    MonriHttpMethod.POST,
                                    headers
                            );

                    // Print full request details
                    System.out.println("Making request to: " + BASE_URL + "/v2/payment/new");
                    System.out.println("With headers: " + headers);

                    OutputStreamWriter wr = null;
                    try {
                        wr = new OutputStreamWriter(urlConnection.getOutputStream());
                        wr.write(bodyAsString);
                        wr.flush();
                    } finally {
                        if (wr != null) {
                            wr.close();
                        }
                    }

                    try {
                        int responseCode = urlConnection.getResponseCode();
                        System.out.println("Response code: " + responseCode);

                        InputStream inputStream;
                        if (responseCode >= 200 && responseCode < 300) {
                            inputStream = new BufferedInputStream(urlConnection.getInputStream());
                        } else {
                            inputStream = new BufferedInputStream(urlConnection.getErrorStream());
                        }

                        // Read response
                        BufferedReader r = new BufferedReader(new InputStreamReader(inputStream));
                        StringBuilder jsonStringResponse = new StringBuilder();
                        for (String line; (line = r.readLine()) != null; ) {
                            jsonStringResponse.append(line).append('\n');
                        }

                        String responseString = jsonStringResponse.toString();
                        System.out.println("Response from server: " + responseString);

                        // Check if response looks like HTML
                        if (responseString.trim().startsWith("<")) {
                            System.out.println("Error: Server returned HTML instead of JSON");
                            return null;
                        }

                        try {
                            JSONObject jsonResponse = new JSONObject(responseString);
                            if (jsonResponse.has("client_secret")) {
                                return jsonResponse.getString("client_secret");
                            } else {
                                System.out.println("Response doesn't contain client_secret: " + responseString);
                                return null;
                            }
                        } catch (Exception e) {
                            System.out.println("JSON parsing error: " + e.getMessage());
                            e.printStackTrace();
                            return null;
                        }
                    } finally {
                        urlConnection.disconnect();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }

            @Override
            protected void onPostExecute(final String value) {
                super.onPostExecute(value);
                consumer.accept(value);
            }
        };
    }

    // Add this helper method to generate the digest
    private static String generateDigest(String key, long timestamp, String authenticityToken, String bodyAsString) {
    String input = key + timestamp + authenticityToken + bodyAsString;
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-512");
        byte[] hashedBytes = md.digest(input.getBytes(StandardCharsets.UTF_8));
        
        // Convert bytes to hex string
        StringBuilder hexString = new StringBuilder();
        for (byte b : hashedBytes) {
            String hex = String.format("%02x", b);
            hexString.append(hex);
        }
        return hexString.toString();
        
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException("SHA-512 algorithm not available", e);
    }
    }

    public static String sha512(String input) {
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-512");
        byte[] hashedBytes = md.digest(input.getBytes(StandardCharsets.UTF_8));
        
        // Convert bytes to hex string
        StringBuilder hexString = new StringBuilder();
        for (byte b : hashedBytes) {
            String hex = String.format("%02x", b);
            hexString.append(hex);
        }
        return hexString.toString();
        
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException("SHA-512 algorithm not available", e);
    }
}

    public void createPaymentSessionNEW(Consumer<String> consumer){
        executor.execute(new Runnable() {
            @Override
            public void run() {

                //Background work here

                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        //UI Thread work here
                    }
                });
            }
        });
    }
}
