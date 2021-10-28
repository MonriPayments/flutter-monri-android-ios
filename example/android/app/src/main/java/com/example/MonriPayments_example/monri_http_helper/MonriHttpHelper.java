package com.example.MonriPayments_example.monri_http_helper;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONObject;

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

    //todo error consumer...
    public static AsyncTask<Void, Void, String > createPaymentSession(Consumer<String> consumer){
         return new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(final Void... voids) {

                try {

                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("add_payment_method", false);

                    String baseUrl = "https://mobile.webteh.hr/";

                    final HttpURLConnection urlConnection =
                            createHttpURLConnection(
                                    baseUrl + "example/create-payment-session",
                                    MonriHttpMethod.POST,
                                    new HashMap<>()
                            );

                    OutputStreamWriter wr = null;

                    try {
                        wr = new OutputStreamWriter(urlConnection.getOutputStream());
                        wr.write(jsonObject.toString());
                        wr.flush();

                    } finally {
                        if (wr != null) {
                            wr.close();
                        }
                    }

                    //now read response
                    try {
                        InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                        BufferedReader r = new BufferedReader(new InputStreamReader(in));
                        StringBuilder jsonStringResponse = new StringBuilder();
                        for (String line; (line = r.readLine()) != null; ) {
                            jsonStringResponse.append(line).append('\n');
                        }

                        JSONObject jsonResponse = new JSONObject(jsonStringResponse.toString());

                        String clientSecret = "";

                        if (jsonResponse.has("client_secret")) {
                            clientSecret = jsonResponse.getString("client_secret");
                        }

                        return clientSecret;

                    } finally {
                        urlConnection.disconnect();
                    }

                } catch (Exception e) {
                    System.out.println("Error while creating payment");
                }

                return null;
            }

            @Override
            protected void onPostExecute(final String value) {
                super.onPostExecute(value);
                consumer.accept(value);
            }
        };
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
