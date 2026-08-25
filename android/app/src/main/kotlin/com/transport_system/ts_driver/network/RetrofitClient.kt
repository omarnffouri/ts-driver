package com.transport_system.ts_driver.network

import com.google.gson.GsonBuilder
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class RetrofitClient {

    companion object{

        fun getClient( baseUrl : String) : ApiInterface {

            val loggingInterceptor  = HttpLoggingInterceptor()
            loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY)

            val gson = GsonBuilder()
                .setLenient()
                .create()

            val client = OkHttpClient()
                .newBuilder()
                .addInterceptor(RequestInterceptor())
                .addInterceptor(loggingInterceptor)
                .build()

            val apiService: ApiInterface by lazy {
                Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create(gson))
                    .build()
                    .create(ApiInterface::class.java)
            }
            return  apiService
        }
    }
}


// Define an interceptor to modify responses
private class RequestInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {

        val request = chain.request()
            .newBuilder()
            .addHeader("Accept","application/json")
            .addHeader("Content-Type","application/json")
            .build()

        return chain.proceed(request)
    }
}