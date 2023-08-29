/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
 *
 * hsas_h4o5f_app is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * hsas_h4o5f_app. If not, see <https://www.gnu.org/licenses/>.
 */

package cn.edu.hsas.h4o5f_app

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val orientationChannel = flutterEngine?.dartExecutor?.let {
        MethodChannel(
            it.binaryMessenger,
            "hsas_h4o5f_app/screen_rotation"
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO
        orientationChannel?.setMethodCallHandler { call, result ->
            if (call.method == "get") {
                result.success(Build.VERSION.SDK_INT.let {
                    when {
                        (it >= Build.VERSION_CODES.R) -> {
                            @Suppress("NewApi")
                            display?.rotation
                        }
                        else -> {
                            @Suppress("DEPRECATION")
                            windowManager.defaultDisplay.rotation
                        }
                    }
                })
            } else {
                result.notImplemented()
            }
        }
    }
}
