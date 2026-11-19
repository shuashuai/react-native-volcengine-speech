module VolcengineSpeech
  def self.exclude_simulator_libraries(installer)
    # SpeechEngineToB 0.0.15.0 缺少 x86_64 模拟器链接所需的原生符号。
    installer.aggregate_targets.each do |target|
      target.user_build_configurations.each_key do |name|
        path = target.xcconfig_path(name)
        contents = path.read
        flags = contents[/^OTHER_LDFLAGS = (.*)$/, 1]
        next unless flags&.include?('-l"speechsdk"')

        # 条件设置继承无条件值会把已经移除的库重新加回来。
        simulator_flags = flags.delete_prefix('$(inherited) ').gsub(
          /(?:^|\s)-l"(?:SpeechEngineToB|SpeechEngineToB_SpeechEngineToB_awesome_ios|speechsdk)"/,
          ''
        )
        setting = "OTHER_LDFLAGS[sdk=iphonesimulator*] = #{simulator_flags}"
        simulator_setting = /^OTHER_LDFLAGS\[sdk=iphonesimulator\*\] = .*$/
        updated = if contents.match?(simulator_setting)
                    contents.sub(simulator_setting) { setting }
                  else
                    "#{contents.chomp}\n#{setting}\n"
                  end
        path.write(updated) if updated != contents
      end
    end
  end
end
