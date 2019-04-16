#--*-coding:utf-8-*--

class Cthulhu < DiceBot

  def initialize
    #$isDebug = true
    super
    @special_percentage		= 20
    @critical_percentage	= 1
    @fumble_percentage 	= 1
    @max_dice	= 100 
    @min_dice	= 1
    @changeexp  = false
    @exp_dice   = false
    #           
  end

  def gameName
    'クトゥルフ'
  end
  
  def gameType
    "Cthulhu"
  end

#=====================================================================================================================
#**　　　　　コマンドPREFIXS
#=====================================================================================================================

  def prefixs
     ['CC(B)?\(\d+\)', 'CC(B)?.*','RES(B)?.*', 'CBR(B)?\(\d+,\d+\)',
      'INI.*','ST.*','IN.*','PHILIA.*','PHOBIA.*','OPP.*','TDHK',
      'PCCB.*','READ.*','DRIVE.*','SC.*','\[.*\]','GUN.*','TNP','ZZ']
  end

  
#=====================================================================================================================
#**　　　　　メッセージINFO
#=====================================================================================================================

  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
[判定ダイス系コマンド]CC,CCB
	■x,yは特に表記がない限り技能値
	■x,yには計算式が使用可能
	CC		:目標値なしでも判定が出ます
	CCx		:判定つき1d100ロール
	CCx[n]		:nは故障ナンバー、故障付き判定
	CCxC　　	:計算、割り算は切捨
	CCxM　　	:目標値の自動修正なし
	CCx,y　　	:x､yは能力値、組合せロール
	CCx:y		:対抗ロール
	CCxXn　　	:n回CCBを振る、最大100回
	CC<技能名>	:初期値で振る、ローマ字可
[狂気系コマンド]IN,PH
	■xはSAN値
	INSANx		:短期の一時的狂気をランダムで決定
	INSANSx 	:ホラーショウのスタンダード
	INSANEx　	:ホラーショウの逃げ場がない場合
	INSANMx　	:ホラーショウの化物と対峙した時
	INSANDOx　	:奇妙な探索者の深き者の混血種
	INSANCUx　	:奇妙な探索者の狂信者
	INSANHEx　	:比叡山炎上
	INSANZBx　	:ゾンビルフ、血液による
	INSANZx　	:ゾンビルフ
	INSANCATx	:猫探索者
	INDEFx		:長期の一時的狂気をランダムで決定
	INDEFCx　	:不定領域の計算
	INDEFHx　	:ホラーショウの即効型か潜伏型
	INDEFHHx　	:ホラーショウの即効型
	INDEFHLx　	:ホラーショウの潜伏型
	INDEFHEx　	:比叡山炎上
	INDEFZHx　	:ゾンビルフ即効型
	INDEFZLx　	:ゾンビルフ潜伏型
	INCUBx		:幻夢郷の狂気
	INCUBSx　	:幻夢郷の狂気(KP選択と探索者の起床なし)
	INx		:INSANとINDEFからどちらか選出
	INSDx		:INSANとINDEFを同時に
	INSQ		:後遺症の選出
	ZZ		:生前の記憶
	PHILIA		:奇妙な性的嗜好
	PHOBIA		:恐怖症
[計算式]
	＋,-,*,/　	:四則演算、順に＋－×÷
	%　　　　　	:結果に対し、割合を計算
	nDx　　　　	:ダイスロール
INFO_MESSAGE_TEXT
  end


#=====================================================================================================================
#**　　　　　コマンドケース
#=====================================================================================================================

  def rollDiceCommand(command)
    output = '1'
    total_n = ""
    type = ""

    command = command.gsub(/？/,"?").gsub(/％/,"%")
    command = command.gsub(/</,"<=").gsub(/<==/,"<=")

    case command
    when /PCCB/i
      # 5%
      @critical_percentage = 5
      @fumble_percentage   = 10
      @exp_dice            = @changeexp
      return getCheckResult(command)
    when /CCB/i
      # 5%
      @critical_percentage = 5
      @fumble_percentage   = 5
      @exp_dice            = @changeexp
      return getCheckResult(command)
    when /CC/i
      # 1%
      @critical_percentage = 1
      @fumble_percentage   = 1
      @exp_dice            = @changeexp
      return getCheckResult(command)
    when /RESB/i
      # 5%
      @critical_percentage = 5
      @fumble_percentage   = 5
      @exp_dice            = @changeexp
      return getRegistResult(command)
    when /CBRB/i
      # 5%
      @critical_percentage = 5
      @fumble_percentage   = 5
      @exp_dice            = @changeexp
      return getCombineRoll(command)
    when /RES/i
      # 1%
      @critical_percentage = 1
      @fumble_percentage   = 1
      @exp_dice            = @changeexp
      return getRegistResult(command)
    when /CBR/i
      # 1%
      @critical_percentage = 1
      @fumble_percentage   = 1
      @exp_dice            = @changeexp
      return getCombineRoll(command)
    when /ST/i
      return get_st(command)
    when /OPP/i
      return get_opp(command)
    when /PHILIA/i
      return get_philia_table(command)
    when /PHOBIA/i
      return get_phobia_table(command)
    when 'TDHK'
      return get_tdhk_table
    when /INIC/i
      @critical_percentage = 1
      @fumble_percentage   = 1
      return getIni(command)
    when /INI/i
      @critical_percentage = 5
      @fumble_percentage   = 5
     return getIni(command)
    when /IN/i
      return get_in(command)
    when /READ/i
      return get_read(command)
    when /DRIVE/i
      return get_drive(command)
    when /SC/i
      return super_choice(command)
    when /GUN/i
      return gun(command)
    when /\[.*\]/i
      return ex_command(command)
    when /TNP/i
      return tnp(command)
    when /ZZ/i
      r=noDice(1,6)-1
      t=['名前','家族','仕事','趣味','死因','宝物']
      return "失われた生前の記憶 : #{t[r]}"
    end
    return nil
  end

  def noDice(min,max)
    max = check_dice(max,min,100)
    min = check_dice(min,1,max)
    point = max - min + 1
    dice,flag = 0,0

    case point
    when 4,6,8,10,12,20,100
      dice = point + 1
      flag = 1
    else
      dice = point
    end

    total_n = rand(dice) + min
    if( flag == 1 )
      total_n = rand(dice) + min while total_n > max
    else
      total_n = rand(dice) + min
    end

    if( @exp_dice )
      testfor = rand(5)
      if( testfor == 0 )
        total_n = rand(99) + 1
      end
    end

    return total_n
  end

#=====================================================================================================================
#**　　　　　デフォルトロール
#=====================================================================================================================
  def getCheckResult(command)

    output = ""
    broken_num = 0
    diff = 0
    numa = 0
    numb = 0

    if (/CCBTESTFOR/i =~ command)
      result = []
      total = 0
      for i in 0..99
        total_n = noDice(@min_dice,@max_dice)
        visual_dice_check = noDice(1,100-i)
        visual_dice_check = noDice(i+1,100)
        result << total_n.to_i
        total = result[i] + total
      end
      return "DICE CHECKING...  \nDICE RESULT : [#{result.sort.join(",")}]  \nTOTAL : #{total}/5050  \nAVERAGE : #{total/100}/50.5"

#=======================================#
#*	故障ナンバー各補正値	       *#
#=======================================#
    elsif (/CC(B)?(<=)?([\d\+\-\/\*\(\)\%D]+)\[(\d+)/i =~ command)
      diff = calc_dice($3)
      broken_num = $4.to_i

#=================================#
#*          CBRB省略形           *#
#=================================#
    elsif (/CC(B)?(<=)?([\d\+\-\/\*\(\)\%D]+)(,|，|、)([D\d\+\-\/\*\(\)\%]+)(M)?/i =~ command)
      numa = calc_dice($3)
      numb = calc_dice($5)
      numa = 1 if numa < 1
      numb = 1 if numb < 1

      if( $6 != "M" )
        numa = check_dice(numa,1,100-@fumble_percentage)
        numb = check_dice(numb,1,100-@fumble_percentage)
      end

      return getCombineRoll("CBRB(#{numa},#{numb})")

#=================================#
#*          RESB省略形	         *#
#=================================#
    elsif (/CC(B)?(<=)?([\d\+\-\/\*\(\)\%D]+)(:|：)([\d\+\-\/\*\(\)\%D]+)/i =~ command)
      numa = calc_dice($3)
      numb = calc_dice($5)
      numa = numa - numb

      return getRegistResult("RESB#{numa}")

#=======================================#
#*		一括CCB		       *#
#=======================================#
    elsif (/CC(B)?([\d\+\-\/\*\(\)\%D]+)?X([\d\+\-\/\*\(\)\%D]+)(\$MARK)?(\$RECORD)?,?(.*)?/i =~ command)
      num  = calc_dice($3)
      diff = calc_dice($2)
      output_dice = []
      output_mark = []
      mark,record = $4,$5
      output = "(CC#{$1}#{diff}) ＞\n               "

      diff = check_dice(diff,1,100-@fumble_percentage)
      num  = check_dice(num,1,300)

      target_name = ($6 == nil) ? nil : $6.split(",")
      target      = []

      fum,cre,spe,suc,fil = 0,0,0,0,0
      for i in 1..num do
        dice   = noDice(1,100)
        output_dice << dice
        target << target_name[noDice(1,target_name.length)-1] if target_name
        if( dice > 100-@fumble_percentage )
          fum = fum + 1
          output_mark << "?"
        elsif( dice > diff )
          fil = fil + 1
          output_mark << "×"
        elsif( dice > @critical_percentage )
          suc = suc + 1
          output_mark << "○"
        else
          cre = cre + 1
          output_mark << "◎"
        end
      end
      output += "[#{output_dice.join(",")}] ＞\n               "
      output += "[#{output_mark.join(",")}] ＞\n               " if mark
      output += "[#{output_dice.sort.join(",")}] ＞\n"
      output =  output.gsub("               ","\n")              if num > 33
      if( record )
        deflection = 0
        standard_deviation = 0
        total = output_dice.inject(:+)
        for i in 1..num do
          deflection += (output_dice[i].to_i-total/num)**2
        end
        standard_deviation = (deflection/num)**(1/2.0)
        skewness = 0
        for i in 1..num do
          skewness += ((output_dice[i].to_i-total/num)/standard_deviation)**3
        end
        skewness = (skewness * num)/((num-1)*(num-2))
        output += "               クリティカル率 #{(cre*100)/(num*1.0)}%\n"
        output += "               ファンブル率   #{(fum*100)/(num*1.0)}%\n"
        output += "               合計値/期待値  #{total}/#{505*num/10}\n"
        output += "               平均値/期待値  #{total/num}/50.5\n"
        output += "               標準偏差         #{standard_deviation}\n"
        output += "               歪度              #{skewness}"
      elsif( target[0] )
        for i in 1..num do
          output += "               #{target[i-1]} : #{output_mark[i-1]}\n"
        end
      else
        output += "               致命的失敗　#{fum}回\n" if fum > 0 
        output += "               失敗           #{fil}回\n" if fil > 0
        output += "               成功           #{suc}回\n" if suc > 0
        output += "               決定的成功　#{cre}回\n" if cre > 0
      end
      return "#{output}"

#=======================================#
#*		CCBIFコマンド	       *#
#=======================================#
    elsif (/CC(B)?(<=)?([D\d\+\-\/\*\(\)\%]+(>[D\d\+\-\/\*\(\)\%]+)+)/i =~ command)
      type_b = $1
      diffArray = $3.split(">")
      if(diffArray.length>10)
        return "要素が多すぎます(最大20個)"
      end
      success = []
      result  = []

      output = "(CC#{text = (@critical_percentage == 1) ? "" : "B"}#{diffArray.join(">")}) ＞\n"
      for i in 1..diffArray.length do
        diff = calc_dice(diffArray[i-1])
        diff = check_dice(diff,1,100-@fumble_percentage)
        result << noDice(@min_dice,@max_dice)
        result[i-1] = check_dice(result[i-1],1,100)

        if( @special_percentage > 0)
          diff_special = (diff * @special_percentage / 100).floor
          diff_special = 1 if diff_special < 1
        end
        if( result[i-1] <= @critical_percentage && result[i-1] <= diff )
          success << "決定的成功"
        elsif(result[i-1] <= diff_special)
          success << "スペシャル"
        elsif(result[i-1] <= diff)
          success << "成功"
        elsif(result[i-1] > 100-@fumble_percentage)
          success << "致命的失敗"
        else
          success << "失敗"
        end
        output += "               (CC#{text = (@critical_percentage == 1) ? "" : "B"}#{diff}) ＞ #{result[i-1]} ＞ #{success[i-1]}\n"
        if( success[i-1] == "致命的失敗" || success[i-1] == "失敗" )
          break
        end
      end
      
      return "#{output}"

#=======================================#
#*		通常CCB各補正値	       *#
#=======================================#
    elsif (/CC(B)?(<=)?([D\d\+\-\/\*\(\)\%]+)([CM])?/i =~ command)
      cmode = $4
      str = $3
      type_b = $1

      return "ERROR:/0" if str.match(/\/0/)
      diff = calc_dice(str)

      return "計算結果 ＞ #{diff}" if cmode == "C"

      diff = 1 if diff < 1
      if( cmode != "M" )
        diff = 100-@fumble_percentage if diff > 100-@fumble_percentage
      end

#=================================#
#*	　　INIダイス	         *#
#=================================#
    elsif (/CCB(.+)/i =~ command)
      rini = $1
      return getIni("INI#{rini}")

#=================================#
#*	ぴよきちダイス	         *#
#=================================#
    elsif (/PCCB(<=)?(\d\+\-\/\*\(\)\%D)/i =~ command)
      diff = calc_dice($2)
      @fumble_percentage = 10
    end

#============================#
#*	CCB処理		    *#
#============================#
    if (diff > 0)
      output += "(CC#{text = (@critical_percentage == 1) ? "" : "B"}#{diff})"

      broken_num = 100 if broken_num > 100
      if (broken_num > 0)
        output += " 故障[#{broken_num}]"
      end

      #=======================================================#
      #*		    ROLL		    	     *#
      #=======================================================#
      #total_n, = noDice(1, 100)
       total_n = noDice(@min_dice,@max_dice)
       total_n = check_dice(total_n,1,100)

      output += ' ＞ ' + "#{total_n}"
      output += ' ＞ ' + getCheckResultText(total_n, diff, broken_num)

    else
      # 1D100単純置換扱い
      output += "(CC#{txet = (@critical_percentage == 1) ? "" : "B"})"

      #=======================================================#
      #*		    ROLL		    	     *#
      #=======================================================#
      #total_n, = noDice(1, 100)
       total_n = noDice(@min_dice,@max_dice)
       total_n = check_dice(total_n,1,100)

      output += ' ＞ ' + "#{total_n}"
      if(total_n > 100-@fumble_percentage)
          output += '＞ ' + "致命的失敗"
      elsif(total_n <= @critical_percentage)
          output += '＞ ' + "決定的成功"
      end
    end

    return output
  end

#============================#
#*	CCB出力		    *#
#============================#
  def getCheckResultText(total_n, diff, broken_num = 0)
    result = ""
    diff_special = 0

    if( @special_percentage > 0)
      diff_special = (diff * @special_percentage / 100).floor
      diff_special = 1 if diff_special < 1
    end

    result = 
      if( total_n > diff )
        if( total_n > 100 - @fumble_percentage )
          "致命的失敗"
        else
          "失敗"
        end
      else
        if( total_n <= @critical_percentage && total_n <= diff_special )
          "スペシャル/決定的成功"
        elsif( total_n <= @critical_percentage )
          "決定的成功"
        elsif( total_n <= diff_special )
          "スペシャル"
        elsif( total_n <= diff )
          "成功"
        end
      end

    if(broken_num > 0)
      if(total_n >= broken_num)
        if(result == "致命的失敗")
          result = "故障/致命的失敗"
        else
          result = "故障"
        end
      end
    end

    return result
  end

#============================#
#*	RESB処理	　  *#
#============================#
  def getRegistResult(command)
    output = "1"

    return output unless(/RES(B)?([-\d]+)/i =~ command)

    value = $2.to_i
    target =  value * 5 + 50

    return "(CC#{text = (@critical_percentage == 1) ? "" : "B"}0) ＞ 自動失敗"   if target < 5
    return "(CC#{text = (@critical_percentage == 1) ? "" : "B"}100) ＞ 自動成功" if target > 100

      #=======================================================#
      #*		    ROLL		    	     *#
      #=======================================================#
      #total_n, = noDice(1, 100)
       total_n = noDice(@min_dice,@max_dice)
       total_n = check_dice(total_n,1,100)

    result =  getCheckResultText(total_n, target)

    return "(CC#{text = (@critical_percentage == 1) ? "" : "B"}#{target}) ＞ #{total_n} ＞ #{result}"
  end
  
#============================#
#*	CBRB処理	    *#
#============================#
  def getCombineRoll(command)
    output = "1"
    return output unless(/CBR(B)?\((\d+),(\d+)\)/i =~ command)
    
    diff_1 = $2.to_i
    diff_2 = $3.to_i

      #=======================================================#
      #*		    ROLL		    	     *#
      #=======================================================#
      #total_n, = noDice(1, 100)
       total_n = noDice(@min_dice,@max_dice)
       total_n = check_dice(total_n,1,100)

    result_1 = getCheckResultText(total_n, diff_1)
    result_2 = getCheckResultText(total_n, diff_2)
    
    successList = ["スペシャル/決定的成功", "決定的成功", "スペシャル", "成功"]
    failList = ["失敗", "致命的失敗"]
    
    succesCount = 0
    succesCount += 1 if successList.include?( result_1 )
    succesCount += 1 if successList.include?( result_2 )
    debug("succesCount", succesCount)
    
    rank = 
      if( succesCount >= 2 )
        "成功"
      elsif( succesCount == 1 )
        "部分的成功"
      else
        "失敗"
      end
 
    if( result_1 == "決定的成功" || result_2 == "決定的成功" )
          rank = "決定的成功"
    elsif( result_1 == "スペシャル/決定的成功" || result_2 == "スペシャル/決定的成功" )
          rank = "スペシャル/決定的成功"
    elsif( result_1 == "致命的失敗" || result_2 == "致命的失敗" )
          rank = "致命的失敗"
    elsif( result_1 == "スペシャル" || result_2 == "スペシャル" )
          rank = "スペシャル"
    end

    
    return "(CC#{txet = (@critical_percentage == 1) ? "" : "B"}#{diff_1},#{diff_2}) ＞ #{total_n}[#{result_1},#{result_2}] ＞ #{rank}"
  end

#======================================================================================================================
#**                    狂気表
#=====================================================================================================================

  def get_in(command)
    diff = 0
    san = 0
    nsan = 0
#============================#
#*	INDEF		    *#
#============================#
    if(/INDEF([A-Z]+)?(\d+)?(\?)?/ =~ command)
      type = ( $1 == nil ) ? "DEFAULT" : $1
      san = $2.to_i
      nsan = san-(san+4)/5
      nsan = "help" if $3
      return "不定領域 ＞ #{nsan}" if $1 == "C"
      return indef(nsan,type)

#============================#
#*	INSAN		    *#
#============================#
    elsif(/INSAN([A-Z]+)?(\d+)?(\?)?/ =~ command)
      type = ( $1 == nil ) ? "DEFAULT" : $1
      san = $2.to_i
      nsan = san-(san+4)/5
      nsan = "help" if $3
      return "不定領域 ＞ #{nsan}" if $1 == "C"
      return insan(nsan,type)

#============================#
#*	INCUB		    *#
#============================#
    elsif (/INCUB([A-Z]+)?(\d+)?(\?)?/i =~ command)
      type = ( $1 == nil ) ? "DEFAULT" : $1
      san = $2.to_i
      nsan = san - (san+4) / 5
      nsan = "help" if $3
      return "不定領域 ＞ #{nsan}" if $1 == "C"
      return get_incub_table(nsan,type)

#============================#
#*	INSD		    *#
#============================#
    elsif(/INSD(\d+)?/i =~ command)
      san = $1.to_i
      nsan = san - (san+4) / 5
      insan = insan(0,"DEFAULT")
      indef = indef(nsan,"DEFAULT")
      return "一時と不定の同時発狂 ＞ \nCthulhu : #{insan}\nCthulhu : #{indef}"

#============================#
#*	INSQ		    *#
#============================#
    elsif(/INSQ(\?)?/i =~ command)
      return select_sequelae(3) if $1 == "?"
      return select_sequelae(2)

#============================#
#*	IN		    *#
#============================#
    elsif(/IN(\d+)?/i =~ command)
      san = $1.to_i
      nsan = san - (san+4) / 5
      insanity = noDice(1,2)
      return "#{output = (insanity == 1) ? insan(nsan,"DEFAULT") : indef(nsan,"DEFAULT")}"
    end

    return nil
  end

#===================================================================================================
#*	INSAN処理部
#===================================================================================================
  def insan(nsan,type)
    key_table = {
      "DEFAULT" => { :key => 0 , :name => "短期の一時的狂気"},
      "DO"      => { :key => 1 , :name => "深きものの短期の一時的狂気"},
      "CU"      => { :key => 2 , :name => "狂信者の短期の一時的狂気"},
      "CAT"     => { :key => 3 , :name => "狂気反応表"},
      "S"       => { :key => 4 , :name => "ホラーショウの短期の一時的狂気(スタンダード)"},
      "E"       => { :key => 5 , :name => "ホラーショウの短期の一時的狂気(逃げ場がない)"},
      "M"       => { :key => 6 , :name => "ホラーショウの短期の一時的狂気(怪物との遭遇)"},
      "HE"      => { :key => 7 , :name => "戦国の短期の一時的狂気(怪物との遭遇)"},
      "ZB"      => { :key => 8 , :name => "ゾンビの一時的狂気(出血による)"},
      "Z"       => { :key => 9 , :name => "ゾンビの一時的狂気"},
    }
    insan_table = [[

# 1 : 通常

        '気絶する(精神的なもので応急手当が不可)',		'金切り声を上げる(正常な判断ができない)',
        'パニックで無造作に逃げる(正常な判断不可)',		'パニックで無造作に逃げる(正常な判断不可)',
        '肉体的ヒステリー(頭を掻き毟ったりする)',		'感情の噴出(感情的になりまともな行動不可)',
        '早口で喋る,多弁症(会話での交流ができない)',		'早口で喋る,多弁症(会話での交流ができない)',
        '釘付けにする恐怖(その場で動けなくなる)',		'釘付けにする恐怖(その場で動けなくなる)',
        '殺人癖(絶対に殺そうとする、自分の命も蔑ろにする)',	'自殺癖(何が何でも死ぬ、殺されようとする)',
        '余りにも恐ろしい幻覚(恐ろしい化物など)',		'酷く悲観的な妄想(極度の被害妄想など)',
        '反復動作(対象がなくなれば別の対象になる)',		'反響言語(対象がなくなれば別の対象になる)',
        '異常食(奇妙なものをそのまま食べようとする)',		'異常食(奇妙なものをそのまま食べようとする)',
        '昏迷(混乱して正常な判断ができない)',			'緊張症(動悸や発汗、自律神経の乱れ)',
    ],[

# 2 : 深きもの

	'体に流れる血が叫んでいる。ここにいてはいけない。本能のままにこの場を逃げ出す。',
	'血が沸騰するようだ。理性は失われ、敵味方関係なく攻撃的になってしまう。',
	'指先が硬直する。まるで鉤爪のようだ。本当にこれは自分の手なのだろうか。じっと見つめ動けなくなる。',
	'急に周りの人間が怖くなる。別の生き物に取り囲まれたようだ。誰も信じられない。疑心暗鬼になる。',
	'足がうまく動かない。恐怖で震えてるわけではない。なぜかはねることしか出来ない。回避/２。',
	'声帯が硬直してしまう。うまく声が出せない。咳き込むようなゴボゴボとしか声が出ない。',
	'体が痒い。皮膚の下から何かが突き出るようだ。これはうろこではないだろうか。掻き毟り手が使えず行動はできない。',
	'やけに喉が渇く。息苦しく、激しいことはできない。',
	'大いなるクトゥルフの声が聞こえる。クトゥルフ神話+5%。',
	'1D6をふる。進行度より大きい目が出たら、進行度は1すすむ。',
    ],[

# 3 : 狂信者

	'生半可な知識だからこそこの事象の真意と恐怖に気づく。形振り構わず逃げ出す。',
	'常識を超える恐怖に信念が揺らぎ怖気付く。足が震え動けない。',
	'如何に自分が矮小な存在であるか気付かされる。自ら死を選ぶ。',
	'真の知識のおぞましさに、その知識を持つ自分自身でさえ恐ろしく自暴自棄になる。',
	'自分は賢いと思っていが周りは自分を愚かだと嘲笑う。もう誰も信用できない。',
	'恐怖心が麻痺する。それを持ち帰り自分のものにしたい衝動が抑えられない。',
	'自分の理論が全て正しい。周りの言うことは下らない。利己的行動しかできない。',
	'眼前の事象に釘付けだ。危険を顧みず更に奥へと足を踏み出す。誰にも邪魔はさせない。',
	'神(KP)からの言葉を聞く。その言葉に従うことに疑問はない。どんなに無謀でも実行する。',
	'恐怖を体感したことでこれまでの知識の断片が繋がった。涙が止まらない。クトゥルフ神話+5%。',
    ],[

# 4 : 猫探索者

	'逃走：可能ならばこの恐怖対象から逃げださなければならない。逃げ出せない場合凍り付き。時間：瞬間',
	'逃走：可能ならばこの恐怖対象から逃げださなければならない。逃げ出せない場合凍り付き。時間：瞬間',
	'逃走：可能ならばこの恐怖対象から逃げださなければならない。逃げ出せない場合凍り付き。時間：瞬間',
	'逃走：可能ならばこの恐怖対象から逃げださなければならない。逃げ出せない場合凍り付き。時間：瞬間',
	'凍り付き：凍り付く。神話存在が自分に何らかのアクションをした場合は狂気ストレス障害表を振る。時間：遭遇中 ',
	'凍り付き：凍り付く。神話存在が自分に何らかのアクションをした場合は狂気ストレス障害表を振る。時間：遭遇中 ',
	'服従：生き延びるために何でも行う。狂気ストレス障害表を2回振り、怪物に服従する。時間：遭遇中 ',
	'戦闘：戦う。生き延びると狂気ストレス障害表をする。',
	'戦闘：戦う。生き延びると狂気ストレス障害表をする。',
	'戦闘：戦う。生き延びると狂気ストレス障害表をする。',
    ],[

# 5 : ホラーショウスタンダード

	'別人格を生み出し、一人で会話する',			'破壊衝動に駆られる',
	'自傷行為をする',					'ヒステリーを起こし感情が爆発する',
	'疑心暗鬼に陥って探索者を疑う',				'健忘症に陥って狂気の原因を記憶から削除する',
	'間違った方向に頭の回転が速くなり通常の判断ができない',	'パニックを起こしてありえない方向に逃げ出す',
	'感覚が麻痺して無謀な行動を平然と行う',			'恐怖から逃避する為、何が何でも死のうとする',
    ],[

# 6 :  ホラーショウ逃げ場なし

	'一心不乱に祈り続け他に何もできない',			'幼児退行する',
	'恐怖のあまり外からの情報を全て遮断する',		'明かりを求め正常な判断ができず無闇に動き回る',
	'疑心暗鬼に陥って探索者を疑う',				'神経過敏になり些細なことも異常に驚く',
	'気絶する、精神的なもので応急手当が不可',		'近くの壁や誰かの服を掴んでいないと動けない',
	'感覚が麻痺して無謀な行動を平然と行う',			'来る筈のない相手に助けを求め自分では何もできなくなる',
    ],[

# 7 : ホラーショウ怪物と遭遇

	'怪物を観察して文学的記録を残す',			'性格が真逆になる',
	'金切り声を上げる',					'大げさな身振りで怪物を挑発し狙われる',
	'現実逃避をして仮装だとか人形だと思い込む',		'怪物の行動を反復したりモノマネしたり探索者に反旗を翻す',
	'自己保身の為に利己的行動にでる',			'パニックを起こしてありえない方向に逃げ出す',
	'夢だと思い込んでしまい、変な行動に出る',		'恐怖から逃避する為、何が何でも死のうとする',
    ],[

# 8 : 戦国

      'パニックで無造作に逃げる(正常な判断不可)',		'一時的な記憶喪失。アイデアに成功しないと重要なことも思い出せない',
      '軽い幻覚',						'感情的な爆発',
      'POW×1に成功しないと動けなくなる',			'制御不能な震え、行動はDEX×5に成功しないといけない',
      '常軌を逸した反応',					'反響言語(対象がなくなれば別の対象になる)',
      '目の前の食べ物でないものを食べる',			'逃避行動、起こっていることから目を背け幼児化する'

    ],[

# 9 : ゾンビルフ出血

	'目の前の血をなめたくなる',				'手近にある生肉(ゾンビ探索者とか)に噛みつく',
	'爪をかじるついでに指もかじってしまう',			'興奮のあまり雄たけびを上げ続ける',
	'血がゾンビの暴力衝動を掻き立てる',			'自殺癖',
	'湧き上がる血液への渇望を抑えるため、目を覆う',		'心を落ち着けるため一心不乱に祈り続ける',
	'神経が異常に高ぶり、なんでも過敏に反応する',		'血の匂いで、酔っぱらったようにテンションが高くなる',

    ],[

# 10 : ゾンビルフ

	'光を避けるようになる',					'両手が前に出てしまう',
	'視点が定まらず、注意力が散漫になる',			'生態が麻痺して、しゃがれ声になる',
	'急に不安になり、不自然に正体を隠そうとする',		'自分の呪われた運命に悲観的になる',
	'自暴自棄になり、危険なゾンビジョークを飛ばしてしまう',	'脳が腐って、一時的に記憶があいまいになる',
	'何かに執着するようになり、ほかのことに集中できない',	'恐怖から逃避するため、幼児化する',

    ]][key_table[type][:key]]

    result = insan_table[noDice(1,insan_table.length)-1]
    round  = noDice(1,10)+4
    time   = noDice(1,10)
    sequelae = select_sequelae(1)
    other = target(result)

    if( nsan == "help" )
      result = []
      other = "#{key_table[type][:name]}一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      insan_table.each{|insanity|
        result << insanity unless result.include?(insanity)
      }
      other += "#{result.join("\n")}"
      other += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
      return "#{other}"
    end

    if( type == "CAT" )
      output =  "#{key_table[type][:name]} ＞"
      output += "\n               #{result}"
      output += "\n               ＞ #{insan_table[4]}" if result.match(/逃走：/)
      return "#{output}"
    end

    output =  "#{key_table[type][:name]} ＞\n               "   
    output += "#{result}#{other}\n               "
    output += "#{round}ラウンド / #{time}時間\n               "
    output += "不定領域 ＞ #{nsan}\n               " if nsan != 0
    output += "後遺症：#{sequelae}"

    return "#{output}"
  end

#===================================================================================================
#*	INDEF処理部
#===================================================================================================
  def indef(nsan,type)
    key_table = {
      "DEFAULT" => { :key => 0 , :name => "長期の一時的狂気"},
      "CAT"     => { :key => 1 , :name => "狂気ストレス障害表"},
      "H"       => { :key => 2 , :name => "ホラーショウの長期の一時的狂気(ランダム)"},
      "HH"      => { :key => 3 , :name => "ホラーショウの長期の一時的狂気(即効型)"},
      "HL"      => { :key => 4 , :name => "ホラーショウの長期の一時的狂気(潜伏型)"},
      "HE"      => { :key => 5 , :name => "戦国の長期の一時的狂気(怪物との遭遇)"},
      "ZH"      => { :key => 6 , :name => "ゾンビの長期の一時的狂気(即効型)"},
      "ZL"      => { :key => 7 , :name => "ゾンビの長期の一時的狂気(潜伏型)"},
    }
    indef_table = [[

# 1 : 基本

        '健忘症(知的技能の低下･親友などを忘れる)',		'昏迷(年齢退行･激しい物忘れ)',
        '緊張症(非自発的･意思がない)',				'激しい恐怖症(逃走可能･対象は見え続ける)',
        '激しい恐怖症(逃走可能･対象は見え続ける)',		'激しい恐怖症(逃走可能･対象は見え続ける)',
        '余りにも恐ろしい幻覚(恐ろしい化物など)',		'余りにも恐ろしい幻覚(恐ろしい化物など)',
        '余りにも恐ろしい幻覚(恐ろしい化物など)',		'奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',
        '奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',		'奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',
        'フェティッシュ（ある物質・人物に対しての異常執着)',	'フェティッシュ（ある物質・人物に対しての異常執着)',
        'フェティッシュ（ある物質・人物に対しての異常執着)',	'制御不能なチック、会話や文章での交流不可(自由選択)',
        '制御不能なチック(不規則な体の動作・発声の繰返し)',	'会話や文章での交流ができない',
        '心因性視覚障害(字と物体が認識できない、ぼやける)',	'心因性難聴(ショックのあまり音が認識できない)',
        '四肢の機能障害(複数の機能障害、手足が動かないなど)',	'心因反応(常軌を逸した振舞い・支離滅裂)',
        '心因反応(常軌を逸した振舞い・支離滅裂)',		'心因反応(常軌を逸した振舞い・支離滅裂)',
        '偏執症(過大な被害妄想、恨みや嫉妬)',		        '偏執症(過大な被害妄想、恨みや嫉妬)',
        '偏執症(過大な被害妄想、恨みや嫉妬)',		        '強迫観念に囚われる(同じ行動を意思に反して反復する)',
        '強迫観念に囚われる(同じ行動を意思に反して反復する)',	'強迫観念に囚われる(同じ行動を意思に反して反復する)',
    ],[

# 2 : 猫探索者

	'トイレ問題',       					'スプレー行為を含む過度のテリトリー行動',
	'過度のグルーミング',					'自傷行為',
	'うつ ',           					'人々や他の動物から隠れる',
	'人々や他の動物への攻撃性',				'食欲不振',
	'動揺',           					'吸引/咀嚼/摂食障害',
    ],[

# 3 : 潜伏型と即効型
			
	'HL','HH',	# ランダムの場合、HLかHHをランダムで選出してもう一度indefメソッドにぶち込む。
    ],[			
			
# 4 : 即効型

	'幻覚(都合の良いものが見えてくる)',				'妄想(馬鹿げた考えに固執して周囲の言葉を聞かない)',
	'奇妙な性的嗜好(性欲が以上に高まる)',				'間欠性爆発性障害(とにかく怒りっぽくなる)',
	'パニック障害(不定気に突然パニックを起こす)',			'強迫性障害(妙な考えが無限に沸き上がり何も集中できない)',
	'脅迫行為(些細な事が気になり其方を優先してしまう)',		'偏執症(他人が信じられなくなり陰謀を図っていると思い込む)',
	'転換性障害(体調が悪いと主張して同情と注目を集めようとする)',	'身体醜形障害(外見上の問題が気になって何もできない)',
    ],[

# 5 : 潜伏型

	'幻覚(自分にしか見えないものに悩ませられ他が手につかない)',	'妄想(ばかげた考えを周囲に訴えかけて妨害する)',
	'奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',			'ある種の恐怖症(些細なものに恐怖を感じて避ける)',
	'過食症(食事を摂り続けなければ何もできない)',			'解離性健忘症(都合の悪いこと、いやなことを全て忘れてしまう)',
	'脅迫行為(無意味な行為に固執してその他は何もできない)',		'薬物乱用障害(酒やドラッグに依存してしまう)',
	'転換性障害(体調が悪いと主張して同情と注目を集めようとする)',	'フェティッシュ(妙なものに固執するか崇拝する)',
    ],[

# 6 : 戦国

      '一時的な記憶喪失。アイデアに成功しないと重要なことも思い出せない',	'恐怖症、身近なあるものを見るたびに0/1d3の正気度喪失',
      '軽い幻覚',								'奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',
      'フェティッシュ、異様な執着',						'制御不能な震え、行動はDEX×5に精巧しないといけない',
      'ヒステリー、特定の言葉や動作に異様な反応',				'反響言語(対象がなくなれば別の対象になる)',
      '異常食(奇妙なものをそのまま食べようとする)',				'強迫観念にとらわれて同じ行動を繰り返す'

    ],[

# 7 : ゾンビルフ即効型

	'ゾンビ過食症(人肉に対する渇望が抑えきれない)',			'妄想(馬鹿げた考えに固執して周囲の言葉を聞かない)',
	'奇妙な性的嗜好(性欲が以上に高まる)',				'衝動的な暴力行動(とにかく怒りっぽくなる)',
	'広場恐怖症(ゾンビがバレることを恐れ社会参加を避ける)',		'幻覚(自分に都合のいいものが見えるようになる)',
	'脅迫行為(些細な事が気になり其方を優先してしまう)',		'偏執症(他人が信じられなくなり陰謀を図っていると思い込む)',
	'四肢の麻痺･硬直(普通の死体のように体が動かない)',		'身体醜形障害(外見上の問題が気になって何もできない)',

    ],[

# 8 : ゾンビルフ潜伏型

	'ゾンビ過食症(人肉に対する渇望が抑えきれない)',			'薬物乱用障害(酒やドラッグに依存してしまう)',
	'ある種の恐怖症(些細なものに恐怖を感じて避ける)',		'解離性健忘症(都合の悪いこと、いやなことを全て忘れてしまう)',
	'フェティッシュ(妙なものに固執するか崇拝する)',			'偏執症(他人が信じられなくなり陰謀を図っていると思い込む)',
	'奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)',			'妄想(ばかげた考えを周囲に訴えかけて妨害する)',
	'幻覚(自分にしか見えないものに悩ませられ他が手につかない)',	'妄想(ばかげた考えを周囲に訴えかけて妨害する)',
	'脅迫行為(無意味な行為に固執してその他は何もできない)',		'自殺癖(自分の命に執着がなくなる)',	

    ]][key_table[type][:key]]

    result = indef_table[noDice(1,indef_table.length)-1]
    time   = noDice(1,10)
    month  = noDice(1,6)
    sequelae = select_sequelae(2)
    other = target(result)

    if( nsan == "help" )
      other = "#{key_table[type][:name]}一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      result = []
      indef_table.each{|insanity|
        result << insanity unless result.include?(insanity)
      }
      other += "#{result.join("\n")}"
      other += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
      return "#{other}"
    end

    if( type == "CAT" )
      return "#{key_table[type][:name]} ＞\n               #{result}#{other}"
    elsif( type == "H" )
      return indef(nsan,result)
    end

    output =  "#{key_table[type][:name]} ＞\n               "   
    output += "#{result}#{other}\n               "
    output += "#{time}0時間 / #{month}ヶ月\n               "
    output += "不定領域 ＞ #{nsan}\n               " if nsan != 0
    output += "後遺症：#{sequelae}"

    return "#{output}"
  end

#===================================================================================================
#*	INCUB処理部
#===================================================================================================
  def get_incub_table(nsan,type)
    table = [
        '物品、衣服、体の一部が溶けるか恐ろしい物に見える',
        '幻覚や麻痺で自由に逃げ出せない(原因が無くなるまで続く)',
        '自分の周りが溶け原因と共に一人別の場所に取り残される幻覚',
        '仲間が恐ろしい化物に見えその化物は原因となった物に似ている',
        '古傷･病気･怪我が突然再発したり、不自由になってしまう',
        '夢と現実の区別がつかず、思い通りな行動ができない',
        '喪失したSANとPOWの対抗、激しいチックでAPPかDEXが1d3減少',
        '喪失したSANとINTの対抗、眼が覚め髪が白髪になる',
        '喪失したSANとCONの対抗後、CON×10に失敗で心臓発作が起きて死ぬ、成功でCON1減少',
        'キーパーが決める',
    ]

    if( nsan == "help" )
      other = "悪夢の狂気表一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      result = []
      table.each{|insanity|
        result << insanity unless result.include?(insanity)
      }
      other += "#{result.join("\n")}"
      other += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
      return "#{other}"
    else
      output  = "悪夢の狂気 ＞\n"
      output += "               不定領域 ＞ #{nsan}\n" if nsan != 0
      output += "               #{output = (type == "S") ? table[noDice(1,6)-1] : table[noDice(1,table.length)-1] }"
      return "#{output}"
    end
  end

#===================================================================================================
#*	各狂気対象決定の提案
#===================================================================================================
  def target(insan) 
    case insan
    when "反復動作(対象がなくなれば別の対象になる)",
         "反響言語(対象がなくなれば別の対象になる)",
         "酷く悲観的な妄想(極度の被害妄想など)"
         "殺人癖(絶対に殺そうとする、自分の命も蔑ろにする)"
         othertable = [
            '探索者','味方NPC','敵対NPC(怪物含)',
         ]
         other = "\n               対象優先順位 ＞ #{othertable.shuffle.join(" > ")}"

    when "異常食(奇妙なものをそのまま食べようとする)"
         othertable = [
            '自分','探索者','味方NPC','敵対NPC(怪物含)','周囲の物品･生物･昆虫･植物',
         ]
         other = "\n               対象優先順位 ＞ #{othertable.shuffle.join(" > ")}"

    when "余りにも恐ろしい幻覚(恐ろしい化物など)",
         "幻覚(自分にしか見えないものに悩ませられ他が手につかない)"
         othertable = [
            '化物が常に襲い掛かってくる',					'化物が周囲に現れて囲まれてしまい逃げ場がなくなる',
            '周囲の生物や人間全てがみな恐ろしい化物に見える',			'周囲がゆがんで視覚が狂う',
            '自分の体に常に恐ろしい虫や化物が這い回る',				'自分の体が化物自身に見える',
            '周囲の物体が全て血肉に見えて動けなくなる',				'友人が化物に見え、化物が友人に見えてしまう',
            '手に持っているものや大事にしているものが恐ろしいものに見える',	'空や天井から化物の手が伸び永遠に襲い掛かってくる',
         ]
         other = "\n               症状 ＞ #{othertable[noDice(1,othertable.length)-1]}"

    when "四肢の機能障害(複数の機能障害、手足が動かないなど)"
         othertable = [
            '右足、左足',		'右足、右手',		'右足、左手',		'左足、右手',
            '左足、左手',		'右手、左手',		'右足、左足',		'右足、右手',
            '右足、左手',		'左足、右手',		'左足、左手',		'右手、左手',
            '右足、左足、右手',		'右足、左足、左手',	'右足、右手、左手',	'左足、右手、左手',
            '右足、左足、右手',		'右足、左足、左手',	'右足、右手、左手',	'左足、右手、左手',
            '右足、左足、右手',		'右足、左足、左手',	'右足、右手、左手',	'左足、右手、左手',
            '全部',			'全部',			'全部',			'全部',
            '全部',			'全部',			'全部',			'全部',
            '全部',			'全部',			'全部',			'全部',
         ]
         other = "\n               箇所 ＞ " + othertable[noDice(1,othertable.length)-1]

    when "奇妙な性癖嗜好(露出症・過敏性欲・奇形愛好者)"
         other = "\n               " + get_philia_table("PHILIA")

    when "健忘症(知的技能の低下･親友などを忘れる)"
         othertable = [
            '探索者','味方NPC','敵対NPC(怪物含)','現状について',
         ]
         other = "\n               対象優先順位 ＞ #{othertable.shuffle.join(" > ")}"

    when "昏迷(年齢退行･激しい物忘れ)"
         othertable = [
            '年齢退行','激しい物忘れ(何をしていたかを忘れてしまう)',
         ]
         other = "\n               症状 ＞ " + othertable[noDice(1,othertable.length)-1]

    when "余りにも恐ろしい幻覚(恐ろしい化物など)",
         "軽い幻覚"
         othertable = [
            '化物が常に襲い掛かってくる',			'化物が周囲に現れて囲まれてしまい逃げ場がなくなる',
            '周囲の生物や人間全てがみな恐ろしい化物に見える',	'周囲がゆがんで視覚が狂う',
            '自分の体に常に恐ろしい虫や化物が這い回る',		'自分の体が化物自身に見える',
            '周囲の物体が全て血肉に見えて動けなくなる',		'友人が化物に見え、化物が友人に見えてしまう',
            '手に持っているものや大事にしているものが恐ろしいものに見える',
            '空や天井から化物の手が伸び永遠に襲い掛かってくる',
         ]
         other = "\n               症状 ＞ " + othertable[noDice(1,othertable.length)-1]

    when "フェティッシュ（ある物質・人物に対しての異常執着)",
         "フェティッシュ、異様な執着"
         othertable = [
            '物質に対してのネガティブな執着',			'探索者に対してのネガティブな執着',
            '味方NPCに対してのネガティブな執着',		'敵対NPCに対してのネガティブな執着',
         ]
         other = "\n               症状 ＞ " + othertable[noDice(1,othertable.length)-1]

    else
         other = " "
    end
    return "#{other} "
  end


#===================================================================================================
#*	SEQUELAE処理部
#===================================================================================================
  def select_sequelae(number)
    sequelae1 = [
        '全般性不安障害/運動性緊張(苛立ち,長期的な鋭い痛み,落ち着きのなさ.身体的技能が半分)',
        '全般性不安障害/自立性他動性障害(発汗,心拍の上昇,眩暈,過呼吸,顔面紅潮/蒼白)',
        '全般性不安障害/破滅の予感(不安,気苦労,恐れ,ネガティブな思想)',
        '全般性不安障害/警戒(集中力の欠如,不眠症,短期,苛立ち.思考系技能が1/4減少)',
        'パニック障害(恐怖が不連続的な周期で訪れ,死や狂気に対して恐れる)',
        '広場恐怖症(広場に行くとき,POW*1~5に成功させなければならない)',
        '脅迫行為(強迫観念,無意味な行動を1d10R繰り返したり、ある行動をしなければならないと感じる)',
        'PTSD(衝撃的な体験が何年経ってもフラッシュバックする)',
        '単純な恐怖症(原因に対するトラウマ)',
    ]
    sequelae2 = [
	'解離性障害(ストレス過多による記憶障害,自我同一性障害)',
	'感情障害(自身の実際の感情と一致しない,感情の混乱)',
	'欝症(症状が出た時の技能値が10%～30%減少する)',
	'躁症(睡眠障害,正常な判断の欠如)',
	'躁欝症(一週間で入れ替わる.欝:発症時10～30%の技能低下/躁:正常な判断の欠如)',
	'身体化障害(眩暈,無気力,激痛,視覚消失)',
	'心気症(重病を患っていると信じ込む)',
	'醜形障害(自身の容姿または性格に対して極度に自信がない)',
	'解離性遁走(家や職場から逃走し過去を思い出すことができない)',
	'拒食症(SIZとCONの減少)',
	'過食症(自己誘発嘔吐を含む)',
	'夜間恐怖による睡眠障害(ストレスから寝付くことができない)',
	'夢遊病(記憶にないうちに睡眠中移動する)',
	'薬物支配(アルコールを含む,症状の重さによってPOW対抗や技能低下を引き起こす)',
	'ノエシス(自身が選ばれしものだという錯覚)',
	'短期のアモク(暴力的･攻撃的になってしまう)',
	'対人恐怖症(他人に対する不信感)',
    ]
    sequelae2.concat(sequelae1)

    if( number == 1 )
      output = sequelae1[rand(sequelae1.length)] 
    elsif( number == 2 )
      output = sequelae2[rand(sequelae2.length)] 
    else
      output = "後遺症一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      result = []
      sequelae2.each{|insanity|
        result << insanity unless result.include?(insanity)
      }
      output += "#{result.join("\n")}"
      output += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
    end

    return "#{output}"
  end

#=====================================================================================================================
#**　　　　　　　　　性癖表
#=====================================================================================================================
  def get_philia_table(command)
    table = [
		'エメトフィリア【嘔吐愛好】',		'ネクロフィリア【死体愛好】',		'アガルマトフィリア【人形愛好】',
		'エキシビジョニズム【露出愛好】',	'フォミコフィリア【昆虫愛好】',		'ボレアフィリア【極限の緊張感への愛好】',
		'オートネピフィリア【幼児退行嗜好】',	'カニバリズム【食人愛好】',		'ディスモーフォフィリア【異形愛好】',
		'ペドフィリア【少女性愛】',		'アスフィクシオフィリア【低酸素嗜好】',	'アポテムノフィリア【自傷愛好】',
		'エストペクトロフィリア【鏡像愛好】',	'バイゴフィリア【尻愛好】',		'オートアサシノフィリア【自身の死を想像することへの愛好】',
		'ナレートフィリア【口述愛好】',		'デンドロフィリア【樹木愛好】',		'タナトフィリア【死を連想することへの愛好】',	
		'ヒエロフィリア【聖物愛好】',		'ヘマトフィリア【血液愛好】',		'アルトカルシフィリア【踏まれることへの愛好】',
		'アナスティーマフィリア【身長差愛好】','エオニズム【女装(男装)愛好】',		'ジェロントフィリア【老人愛好】',
		'ネピオフィリア【幼児愛好】',		'ニフォフィリア【小児愛好】',		'オキュロフィリア【眼球愛好】',
		'ポドフィリア【脚愛好】',		'トリコフィリア【毛髪愛好】',		'メイシオフィリア【巨乳愛好】',
		'コプロラリア【猥褻語多用癖】',		'アラクネフィリア【蜘蛛愛好】',		'ビースティアルサディズム【動物虐待愛好】',
		'ズードウズーフィリア【擬似動物愛好】','バイストフィリア【強姦愛好】',		'スペクトロフィリア【霊･神･天使への愛好】',
		'ズーフィリア【動物愛好】',		'ヴァンパリズム【吸血愛好】',		'ノソフィリア【病気愛好】',
		'フォボフィリア【恐怖愛好】',		'ゼロフィリア【嫉妬愛好】',		'アクロフィリア【高所愛好】',
		'クラストロフィリア【閉所愛好】',	'アクロトモフィリア【人体解体愛好】',	'アルゴフィリア【苦痛愛好】',
		'ハミロフィリア【説教愛好】',		'ハイブリストフィリア【犯罪者愛好】',	'ペックアティフィリア【犯罪愛好】',
		'フィジャフィリア【逃亡愛好】',		'タフェフィリア【埋葬愛好】',
    ]

    if(/PHILIA\?/i =~ command)
      output = "性癖表一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      output += "#{table.sort.join("\n")}"
      output += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
      return "#{output}"
    elsif(/PHILIA/i =~ command)
      return "異常性癖 ＞ #{table[rand(50)]}"
    end
    return nil
  end


#=====================================================================================================================
#**　　　　　　　　　恐怖表
#=====================================================================================================================

  def get_phobia_table(command)
    table = [
		'アイルロフォビア【猫恐怖症】',		'アクアフォビア【水恐怖症】',		'アクロフォビア【高所恐怖症】',
		'アストラフォビア【雷恐怖症】',		'アストロフォビア【星恐怖症】',		'アンドロフォビア【男性恐怖症】',
		'イアトロフォビア【医者恐怖症】',	'イクスィフォビア【魚恐怖症】',		'エルゴフォビア【仕事恐怖症】',
		'エントモフォビア【虫恐怖症】',		'オーニソフォビア【鳥恐怖症】',		'オノマトフォビア【特定の名称への恐怖症】',
		'オフィディオフォビア【蛇恐怖症】',	'オンドントフォビア【歯(牙)恐怖症】',	'クリノフォビア【ベッド恐怖症】',
		'クローストロフォビア【部屋恐怖症】',	'ゲフィドロフォビア【橋恐怖症】',		'サラッソフォビア【海恐怖症】',
		'ジネフォビア【女性恐怖症】',		'ズーフォビア【動物恐怖症】',		'スコレクシフォビア【毛虫恐怖症】',
		'ゼノフォビア【外国人恐怖症】',		'タフェフォビア【埋葬恐怖症】',		'スペクトロフォビア【霊･神･天使への恐怖症】',
		'デモノフォビア【悪魔恐怖症】',		'デモフォビア【群集恐怖症】',		'デンドロフォビア【樹木恐怖症】',
		'トモフォビア【治療恐怖症】',		'ドラフォビア【毛皮恐怖症】',		'ニクトフォビア【暗所恐怖症】',
		'ネクロフォビア【死体恐怖症】',		'ノクトフォビア【夜恐怖症】',		'パイロフォビア【炎恐怖症】',
		'バクテリオフォビア【細菌恐怖症】',	'バリストフォビア【銃弾(銃)恐怖症】',	'ファゴフォビア【食事恐怖症】',
		'ブレノフォビア【粘液恐怖症】',		'ベスティオフォビア【衣類恐怖症】',	'ペディフォビア【子供恐怖症】',
		'ヘマトフォビア【血液恐怖症】',		'ベローンフォビア【針(先端)恐怖症】',	'ボタノフォビア【植物恐怖症】',
		'モノフォビア【孤独恐怖症】',		'パレオフォビア【古物恐怖症】',		'アマクソフォビア【車恐怖症】',
		'サイバフォビア【電子機器恐怖症】',	'ビブリオフォビア【書籍恐怖症】',	'アリスモフォビア【数字恐怖症】',
		'ヒュプノフォビア【睡眠恐怖症】',	'スコリオノフォビア【学校恐怖症】',
    ]

    if(/PHOBIA\?/i =~ command)
      output = "恐怖症表一覧\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿\n"
      output += "#{table.sort.join("\n")}"
      output += "\n￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
      return "#{output}"
    elsif(/PHOBIA/i =~ command)
      return "恐怖症 ＞ #{table[rand(50)]}"
    end
  end


#=====================================================================================================================
#**　　　　　能力値ロール
#=====================================================================================================================

#============================#
#*	   OPPコマンド	    *#
#============================#
  def get_opp(command)
    size = ["AA(7.5)","A(10.0)","B(12.5)","C(15.0)","D(17.5)","E(20.0)","F(22.5)","G(25.0)","H(27.5)"]
    type = "通常"

    if (/OPPA/i =~ command)
      oppc = [1,51,156,371,649,893,974,995,1000]
      type = "大"
    elsif(/OPPL/i =~ command)
      oppc = [150,650,895,995,1000,9999,9999,9999]
      type = "小"
    else
      oppc = [5,102,380,658,873,973,994,999,1000]
      type = "通常"
    end

    opprand = rand(1000)+1
    for i in 0..oppc.length-1 do 
      if(opprand <= oppc[i])
        opp = size[i]
        return "胸囲(#{type}) ＞ #{opp}"
      end
    end

    return nil
  end

#=================================#
#*	   STATUSコマンド	 *#
#=================================#
  def get_st(command)
    tables = {"小1" => 1 , "小2" => 2 , "小3" => 3 , "小4" => 4 , "小5" => 5 , "小6" => 6 ,
              "中1" => 7 , "中2" => 8 , "中3" => 9 , "高1" => 10 , "高2" => 11 , "高3" => 12 ,
              "1"=>1,"2"=>2,"3"=>3,"4"=>4,"5"=>5,"6"=>6,"7"=>7,"8"=>8,"9"=>9,"10"=>10,"11"=>11,"12"=>12}
    if (/STUDENTMAKE(\d+|[小][1-6]|[中高][1-3]),(\d+|[小][1-6]|[中高][1-3])/i =~ command)
       snum = tables[$1].to_i
       enum = tables[$2].to_i
       if (snum > enum)
         snum,enum = enum,snum
       end
       return studentmake(snum,enum)
    elsif(/STUDENTMAKE(\d+|[小][1-6]|[中高][1-3])/i =~ command)
       return studentmake(1,tables[$1].to_i)
    elsif (/ST(\w+)/i =~ command)
       status = $1.to_s
    end

    case status
    when "STR","CON","POW","APP","DEX","EDU"
        status_num, = roll2(3,6,0)
        status_num += 3 if status == "EDU"
    when "SIZ","INT"
        status_num = roll2(2,6,6)
    else
        str, con, pow, dex = roll2(3,6,0), roll2(3,6,0), roll2(3,6,0), roll2(3,6,0) 
        app, siz, int, edu = roll2(3,6,0), roll2(2,6,6), roll2(2,6,6), roll2(3,6,3)
        str, siz, edu      = roll2(2,6,0), roll2(2,6,0), 6 if status == "UDENT"

        case siz + str
        when 2 .. 12 
           db = "-1d6"
        when 13 .. 16
           db = "-1d4"
        when 17 .. 24
           db = "+0"
        when 25 .. 32
           db = "+1d4"
        when 33 .. 40
           db = "+1d6"
        end

        return "能力値 ＞ 
               STR#{str}  CON#{con}  POW#{pow}  DEX#{dex}  APP#{app} 
               SIZ#{siz}  INT#{int}  EDU#{edu}  HP#{(con + siz + 1) / 2}  MP#{pow}  DB#{db}
               SAN#{pow*5}  アイデア#{int*5}  幸運#{pow*5}  知識#{knowledge = (edu*5 > 95) ? 95 : edu*5}"
    end

    return "能力値 ＞ #{status}#{status_num}"
  end

#============================#
#*	学生探索者ルール    *#
#============================#
  def studentmake(snum,enum)	# snum年生からenum年生の成長 
    output = ""				#中学1年生は7年生扱い(小6+1)
    ini = ""				#同様に高1は10年生扱い(小6+中3+1)
    siz = 0
    strm = 0				#男性の場合のSTR増加量
    strw = 0				#女性の場合のSTR増加量
    edu = 0
    if ( snum == 1 )
      skill = [-15,-25,30,30,-5,30,-15,-9,-9,-20,-10]	#最初から作る場合、補正値を表示する
    else
      skill = [0,0,0,0,0,0,0,0,0,0,0]				#途中から作る場合、補正はしているので増加分のみ。大上用
    end

    for num in snum .. enum do
      #======================#
      #*	小学生成長    *#
      #======================#
      if( num >= 1 && num <= 6 )
        if( num == snum )
          output += "\n#===============================================\n"
          output += "#2つ選択、被りなし、DICE[a,b]の数値を選択した技能の成長欄に加算 \n#==============================================="
        end
        output += "\n	小学#{num}年生　＞　"

        dice = noDice(1,100)
        case dice
        when 1..10
          output += "自然に囲まれて育った\n	《回避》《水泳》《跳躍》《登攀》\n"
        when 11..20
          output += "武道が得意\n	《応急手当》《回避》《投擲》《マーシャルアーツ》《格闘技能･武器技能(火器除く)》\n"
        when 21..30
          output += "国語が得意\n	《芸術(文才)》《図書館》《母国語》《歴史》\n"
        when 31..40
          output += "算数が得意\n	《経理》《コンピュータ》《図書館》《物理学》\n"
        when 41..50
          output += "理科が得意\n	《化学》《生物学》《地質学》《天文学》《物理学》《博物学》\n"
        when 51..60
          output += "社会が得意\n	《考古学》《人類学》《図書館》《歴史》\n"
        when 61..70
          output += "音楽が得意\n	《聞き耳》《芸術(歌唱・楽器)》《製作(楽曲)》\n"
        when 71..80
          output += "図工が得意\n	《機械修理》《芸術(絵画など)》《製作(木工など)》《電気修理》\n"
        when 81..90
          output += "家庭科が得意\n	《信用》《心理学》《製作(裁縫・料理)》\n"
        when 91..95
          output += "外国語が得意\n	《信用》《他言語(英語)》\n"
        else
          output += "遊んでばかりいた\n	《回避》《隠す》《隠れる》《忍び歩き》\n"
        end

        output += "	DICE[#{noDice(1,10)},#{noDice(1,10)}]\n"

      #======================#
      #*	中高生成長    *#
      #======================#
      elsif( num >= 7 && num <= 12)
        if( num == snum || num == 7 || num == 10)
          output += "\n#==============================================="
          output += "\n#4つ選択(例外あり)、被りあり、DICE[a,b,c,d]の数値を選択した技能の成長欄に加算 \n#==============================================="
        end
        if( num == 10 )
          skill[4] += 5
          skill[8] += 5
          skill[9] += 10
          skill[10] += 5
        end
        siz += 1

        dice = noDice(1,6)
        strm += 1 if dice >= 4
        strw += 1 if dice >= 5

        dice = noDice(1,6)

        flag = 0				#0=EDU成長しない　1=EDU成長した　2=EDU成長せずアルバイト
        edu += 1 if dice >= 3
        flag = 1 if dice >= 3		#EDU成長したならば、アルバイトの場合でも４つ技能成長
			
        skill[2] -= 5
        skill[3] -= 5
        skill[5] -= 5

        if( num <= 9 )
          output += "\n	中学#{num-6}年生　＞　"
        else
          output += "\n	高校#{num-9}年生　＞　"
        end
        dice = noDice(1,100)
        case dice
        when 1..10
          output += "運動部でエース\n	《回避》《芸術(スポーツ)》《水泳》《跳躍》《登攀》《棍棒･杖術》\n"
        when 11..20
          output += "武道が得意\n	《応急手当》《回避》《マーシャルアーツ》《格闘技能･武器技能(火器除く)》\n"
        when 21..25
          output += "国語が得意\n	《芸術(文才)》《図書館》《他言語(漢文･古語)》《母国語》《歴史》\n"
        when 26..30
          output += "数学が得意\n	《経理》《コンピュータ》《図書館》《物理学》\n"
        when 31..35
          output += "理科が得意\n	《化学》《生物学》《地質学》《天文学》《物理学》《博物学》\n"
        when 36..40
          output += "社会が得意\n	《考古学》《人類学》《図書館》《歴史》\n"
        when 41..45
          output += "外国語が得意\n	《図書館》《他言語(英語)》\n"
        when 46..50
          output += "音楽が得意\n	《聞き耳》《芸術(歌唱・楽器)》《製作(楽曲)》\n"
        when 51..55
          output += "美術が得意\n	《目星》《芸術(絵画･彫刻)》《歴史》\n"
        when 56..60
          output += "技術が得意\n	《鍵開け》《機械修理》《製作(木工･金属加工)》《電気修理》《目星》\n"
        when 61..65
          output += "家庭科が得意\n	《応急手当》《信用》《心理学》《製作(裁縫・料理)》\n"
        when 66..75
          output += "委員会に所属\n	《言いくるめ》《応急手当》《経理》《信用》《説得》《図書館》\n"
        when 76..80
          output += "文化部に所属\n	《オカルト》《芸術》《経理》《コンピュータ》《写真術》《製作》《図書館》《他言語》《母国語》《歴史》\n"
        when 81..85
          output += "遊んでばかりいた\n	《言いくるめ》《運転》《芸術》\n"
        when 86..90
          output += "海外に行った\n	《信用》《他言語》\n"
        else
          output += "アルバイト・お手伝いに専念した\n	《任意》"
          if ( flag == 1 )						#EDU成長していれば4つ成長
            output += "　EDU上昇のため、4つ選択\n"
          else
            output += "　2つ選択\n"
            flag = 2						#EDU成長なしかつアルバイトでflag=2
          end
        end

        if ( flag <= 1 )
          output += "	DICE[#{noDice(1,10)},#{noDice(1,10)},#{noDice(1,10)},#{noDice(1,10)}]\n"
        else
          output += "	DICE[#{noDice(1,10)},#{noDice(1,10)}]\n"
        end
      end
    end

    if( snum == 1 )
      ini += "\n初期値補正（その他欄に入力）\n"
    else
      ini += "\n初期値補正（その他欄に加算）\n"
    end
    ini += "自動車　#{skill[0]}	応急手当　#{skill[1]}	回避　#{skill[2]}	隠れる　#{skill[3]}\n"
    ini += "機械修理　#{skill[4]}	忍び歩き　#{skill[5]}	二輪車　#{skill[6]}	信用　#{skill[7]}\n"
    ini += "電気修理　#{skill[8]}	図書館　#{skill[9]}	歴史　#{skill[10]}\n"

    ini += "\n能力値成長\n"
    ini += "SIZ+#{siz}		EDU+#{edu}		STR男性+#{strm}　女性+#{strw}\n"

    return "#{ini}#{output}"
  end

#=====================================================================================================================
#**　　　　　　都道府県
#=====================================================================================================================
  def get_tdhk_table
    table = ['北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県',
             '埼玉県','千葉県','東京都','新潟県','富山県','石川県','福井県','山梨県','長野県','神奈川県',
             '岐阜県','静岡県','愛知県','三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県',
             '鳥取県','島根県','岡山県','広島県','山口県','徳島県','香川県','愛媛県','高知県','鹿児島県',
             '佐賀県','長崎県','熊本県','大分県','宮崎県','沖縄県','福岡県',]
    return "都道府県 ＞ #{table[rand(47)]}"
  end


#=====================================================================================================================
#**　　　　　　初期値コマンド
#=====================================================================================================================
  def getIni(command)
    rini = 0
    add = 0
    formula = ""
    outtmp = "CCB"

    if( /INIC/i =~ command )
      command = command.sub(/INIC/,"INI")
      outtmp = "CC"
    end
#=================================#
#*	 　補正値込みINI         *#
#=================================#
    if (/INI([^0-9\+\-\/\*]+)([\d\+\-\/\*\(\)\%D]+)/i =~ command)
       formula = $2
       rini = $1

       if( rini.split(//u).length > 5 )
          if ( rini.length >= 15 )
             rini = rini[0...15]
          else
             rini = rini[0...5]
          end
          if ( rini.split(//u).length > 5 )
             rini = rini[0...5]
          end
       end

#============================#
#*	   通常INI	    *#
#============================#
    elsif (/INI(\w{1,5})/i =~ command)
       rini = $1

    elsif (/INI(<=)?\{SAN\}/i =~ command)
       return "名前が空欄か間違っています。"
    elsif (/INI(<=)?\{SAN値\}/i =~ command)
       return "イニシアティブ表はSAN値ではなくSANです。"

    else
       return "INIの後に技能名を書くと初期値ロールが可能です"

    end

#============================#
#*	  INI処理	    *#
#============================#
    skill = ""

    case rini
    when "拳","こぶし","ぱんち","パンチ","PANTI","PANNT","PUNCH","KOBUS"
         add = add + 50
         skill = "こぶし"

    when "登攀","とうはん","TOUHA","とうはN"
         add = add + 40
         skill = "登攀"

    when "応急手当","おうきゅう","OUKYU"
         add = add + 30
         skill = "応急手当"

    when "ライフル","らいふる","RAIHU","RAIFU"
         add = add + 25
         skill = "ライフル"

    when "キック","きっく","KIKKU"
         add = add + 25
         skill = "キック"

    when "組み付き","くみつき","KUMIT"
         add = add + 25
         skill = "組み付き"

    when "投擲","とうてき","TOUTE"	
         add = add + 25
         skill = "投擲"

    when "聞き耳","ききみみ","KIKIM"
         add = add + 25
         skill = "聞き耳"

    when "目星","めぼし","MEBOS"	
         add = add + 25
         skill = "目星"

    when "図書館","としょかん","TOSYO"
         add = add + 25
         skill = "図書館"

    when "水泳","すいえい","SUIEI"
         add = add + 25
         skill = "水泳"

    when "跳躍","ちょうやく","TYOUY"
         add = add + 25
         skill = "跳躍"

    when "ナイフ","ないふ","NAIHU","KNIFE","NAIFU"
         add = add + 25
         skill = "ナイフ"

    when "杖","つえ","TSUE","TUE","杖術","じょうじゅ","JOUJU"
         add = add + 25
         skill = "杖術"
 
    when "拳銃","けんじゅう","KENJU","KENNJ"
         add = add + 20
         skill = "拳銃"

    when "運転","うんてん","UNTEN","UNNTE"
         add = add + 20
         skill = "運転"

    when "機械修理","きかいしゅ","KIKAI"
         add = add + 20
         skill = "機械修理"

    when "歴史","れきし","REKIS"
         add = add + 20
         skill = "歴史"

    when "サブマシン","さぶましん","SABUM"
         add = add + 15
         skill = "サブマシンガン"

    when "隠す","かくす","KAKUS"
         add = add + 15
         skill = "隠す"

    when "信用","しんよう","SINNY","SHINN","SINYO","SHINN"
         add = add + 15
         skill = "信用"

    when "説得","せっとく","SETTO"
         add = add + 15
         skill = "説得"

    when "頭突き","ずつき","ZUTUK","ZUTSU"
         add = add + 10
         skill = "頭突き"

    when "隠れる","かくれる","KAKURE"
         add = add + 10
         skill = "隠れる"

    when "忍び歩き","しのびある","SINOB"
         add = add + 10
         skill = "忍び歩き"

    when "写真術","しゃしんじ",	"SYASI","SHASI","SYASH","SHASH"
         add = add + 10
         skill = "写真術"

    when "追跡","ついせき","TUISE","TSUIS"
         add = add + 10
         skill = "追跡"

    when "電気修理","でんきしゅ","DENKI","DENNK"
         add = add + 10
         skill = "電気修理"

    when "ナビゲート","NABIG","なびげーと"
         add = add + 10
         skill = "ナビゲート"
  
    when "経理","けいり","KEIRI"
         add = add + 10
         skill = "経理"

    when "博物学","はくぶつが","HAKUB"
         add = add + 10
         skill = "博物学"

    when "乗馬","じょうば","JOUBA"
         add = add + 5
         skill = "乗馬"

    when "製作","せいさく","SEISA"
         add = add + 5
         skill = "製作"

    when "言いくるめ","いいくるめ","IIKUR"
         add = add + 5
         skill = "言いくるめ"

    when "値切り","ねぎり","NEGIR"
         add = add + 5
         skill = "値切り"

    when "医学","いがく","IGAKU"
         add = add + 5
         skill = "医学"

    when "オカルト","OKARU","おかると"
         add = add + 5
         skill = "オカルト"

    when "心理学","しんりがく",	"SINRI","SHINR","SINNR"
         add = add + 5
         skill = "心理学"

    when "法律","ほうりつ","HOURI"
         add = add + 5
         skill = "法律"

    when "鍵開け","かぎあけ","KAGIA"
         add = add + 1
         skill = "鍵開け"

    when "生物学","せいぶつが","SEIBU"
         add = add + 1
         skill = "生物学"

    when "精神分析","せいしんぶ","SEISI","SEISH"
         add = add + 1
         skill = "精神分析"

    when "重機械操作","じゅうきか","JUUKI"
         add = add + 1
         skill = "重機械操作"

    when "操縦","そうじゅう","SOUJU"
         add = add + 1
         skill = "操縦"

    when "変装","へんそう","HENSO","HENNS"
         add = add + 1
         skill = "変装"

    when "化学","かがく","KAGAK"
         add = add + 1
         skill = "化学"

    when "考古学","こうこがく","KOUKO"
         add = add + 1
         skill = "考古学"

    when "コンピュー","KONPY","KONNP","こんぴゅー"
         add = add + 1
         skill = "コンピューター"

    when "人類学","じんるいが","JINRU","JINNR"
         add = add + 1
         skill = "人類学"

    when "地質学","ちしつがく","TISIT","CHISH","CHISI","TISHI"
         add = add + 1
         skill = "地質学"

    when "電子工学","でんしこう","DENSI","DENSH","DENNS"
         add = add + 1
         skill = "電子工学"

    when "天文学","てんもんが","TENMO","TENNM"
         add = add + 1
         skill = "天文学"

    when "物理学","ぶつりがく","BUTUR","BUTSU"
         add = add + 1
         skill = "物理学"

    when "薬学","やくがく","YAKUG"
         add = add + 1
         skill = "薬学"

    when "{SAN}"
         return "名前が間違っているか、空欄です。"

    end

#=================================#
#*	 　INI補正処理		 *#
#=================================#
     formula = "#{add}#{formula}"
     add = calc_dice(formula)

     add = check_dice(add,1,100-@fumble_percentage)
     
     return "#{outtmp}#{add} #{skill}\nCthulhu : " + getCheckResult("CCB<=#{add}")

  end

#=================================#
#*	    READ補正処理	 *#
#=================================#
  def get_read(command)
    if( /READ\?/i =~ command )
        return "\詳細はルルブ151p　本を調べる期間の修正値
第一引数　INT
第二引数　EDU
第三引数　言語技能値
第四引数　オカルト
第五引数　図書館のランク
第六引数　本来解読にかかる期間(週間単位)

第四引数はクトゥルフ神話技能でも可能、その場合は末尾C

例）INT15　EDU21　言語技能値50　オカルト30　図書館のランク5　解読期間52週間
　　READ15,21,50,30,5,52
　　＞　解読期間：39.52週間

例）INT18　EDU24　言語技能値70　神話技能18　図書館のランク20　解読期間52週間
　　READ18,24,70,18C,20,52
　　＞　解読期間：25.48週間"

    elsif( /READ(\d+),(\d+),(\d+),(\d+)(C)?,(\d+),(\d+)/i =~ command )
        int = $1.to_i
        edu = $2.to_i
        lung = $3.to_i
        oka = $4.to_i
        coc = $5
        rank = $6.to_i
        reading = $7.to_f
        point = 0

        point = point + int - 14 if int >14
        point = point + edu - 14 if edu > 14
        if( lung > 5 )
          point = point + lung / 5
        elsif( lung <= 5 )
          point = point - 100
        end
        if( coc == "C" )
          point = point + oka / 5
        elsif( coc != "C" )
          point = point + oka / 20
        end
        point = point + rank
        point = 0 if point < 0
        point = 100 - point
        reading = reading * point / 100
        return "解読期間：#{reading}週間"
    end
  end

#=================================#
#*	     DRIVE処理		 *#
#=================================#
  def get_drive(command)
    if(/DRIVE\?/i =~ command)
      return "詳細は328p
＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿
               ■距離
               車両間距離。速度が1速ければ１距離分の差を広げられる。
               距離1~5まであり、射撃は2で半分、3で1/4、4で1%となる。5は0%。
               
               ■速度変更
               1ラウンドごとに車両に定められた加減速度分だけ加減速が可能。
               最大速度を超える事はなく、最大速度では補正がかかる。

               ■機動
               運転技能に修正値をかけてロールする。
               機動に失敗した場合DRIVEをロールする。
               
               ■運転ロール修正値
               スピン･ターン　-25%
               土の道、大雨、大枝、岩、油、氷結、雪　-20%
               長い下り坂、パンク、霧、砂利道、高速ターン、夜間、雨、風、最大速度　-10%
               ハンドリング　車両による
               速度1、速度2　+10%

               ■車両について　
               おおよそ20km/hにつき速度1
               加減速度は通常2X
               ハンドリングはスポーツカーなどで10~20程度である

               ■機動の種類
               328p参照               
￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
    elsif(/DRIVE([HM])?/i =~ command)
      result = "詳細は328p"
      @drive_type = "NORMAL"
      if( $1 == "H" )
        @drive_type = "H"
      elsif( $1 == "M" )
        @drive_type = "M"
      end
      result = accident(result,0,0)
      return result
    end
  end

  def accident(result,fix,check)
    trouble = [
      '<!>再起回数が10を超えたので強制離脱します。',
      'タイヤのパンク、交換するまで運転-10%、速度-1',
      'エンジン故障、修復するまで速度-2/R、速度0の時1Rかけ機械修理で修復可',
      'ガソリンタンクの破裂、2度目これがでると破損',
      '横滑り、次の運転で-20%','尻振り、次の運転で-10%','尻振り、次の運転で-10%','尻振り、次の運転で-10%',
      '尻振り、次の運転で-15%','ひどい尻振り、次の運転で-30%',
      '回転、速度1につき2d3の車両ダメと1d3のダメ、10%でガソリン引火',
    ]
    trouble_for_monster = [
      '<!>再起回数が10を超えたので強制離脱します。',
      '怪我をする、治療するまでチェイス-10%、速度-1',
      '足を負傷する、治療するまで速度-2/R、速度0の時1Rかけて治療できる',
      '酷い疲労、2度目これがでると動けなくなる',
      'つまづき、次のチェイスで-20%','もたつき、次のチェイスで-10%','もたつき、次のチェイスで-10%','もたつき、次のチェイスで-10%',
      'もたつき、次のチェイスで-15%','つまづき、次のチェイスで-30%',
      '転倒、速度1につき2d3のダメージ、10%で酷い負傷で動けない',
    ]
    trouble_for_horse = [
      '<!>再起回数が10を超えたので強制離脱します。',
      '車輪の故障、交換するまで運転-10%、速度-1',
      '馬の怪我、治療するまで速度-2/R、速度0の時1Rかけ医学で修復可',
      '車体へ亀裂、2度目これがでると故障',
      '横滑り、次の運転で-20%','尻振り、次の運転で-10%','尻振り、次の運転で-10%','尻振り、次の運転で-10%',
      '尻振り、次の運転で-15%','ひどい尻振り、次の運転で-30%',
      '転倒、速度1につき2d3の車両ダメージとPCへ1d3のダメージ',
    ]
    if( @drive_type == "M" )
      trouble = trouble_for_monster
    elsif( @drive_type == "H" )
      trouble = trouble_for_horse
    end
    check += 1
    if( check > 10 )
      return "\n#{trouble[0]}\n#{result}"
    end
    dice = noDice(1,10)+fix
    if( dice == 8 )
      result = result + "\n               [#{dice}]#{trouble[dice]}" #+ " 再起回数　#{check}"
      result = accident(result,2,check)
    elsif( dice == 9 )
      result = result + "\n               [#{dice}]#{trouble[dice]}" #+ " 再起回数　#{check}"
      result = accident(result,4,check)   
    elsif( dice > 10 )
      result = accident(result,0,check)
      result = accident(result,0,check)
    else
      result = result + "\n               [#{dice}]#{trouble[dice]}" #+ " 再起回数　#{check}"
    end
    return result
  end

#=================================#
#*	  SuperChoiceコマンド	 *#
#=================================#
  def super_choice(command)
     if( /SC(W)?(\d+)?,(.+)/i =~ command )
       mode = $1
       count = $2.to_i
       choice = $3
       result = "対象　＞　\n"
       choice = choice.split(",")
       count = check_dice(count,1,15)
       if( choice.length + 1 <= count && mode != "W" )
         count = choice.length
       end
       for num in 1..count do 
         rand_choice = noDice(1,choice.length)-1
         result += "	#{num} : #{choice[rand_choice]}\n"
         choice.delete_at(rand_choice) if mode != "W"
       end
     end
     return result
  end

#=================================#
#*	    GUNコマンド		 *#
#=================================#
  def gun(command)
    if( /GUN([D\d+\+\-\*\/]+),?(\d+)?(M)?,?(\d+)?/i =~ command )
      damage_dice = $1
      rapid_fire  = ($2 == nil) ? 6 : $2.to_i
      armored     = ($4 == nil) ? 0 : $4.to_i
      rapid_fire  = check_dice(rapid_fire,1,100)
      armored     = check_dice(armored,0,99999)
      
      hit         = ($3 == nil) ? noDice(1,rapid_fire) : rapid_fire
      output_ary  = []
      total_damage= 0

      for i in 1..hit do
        damage = calc_dice(damage_dice) - armored
        damage = 0 if damage < 0
        total_damage += damage
        output_ary << damage        
      end
             
      return "命中:#{hit}/#{rapid_fire}発 ＞ [#{output_ary.join(",")}] ＞ #{total_damage}"
    end
    return nil
  end





#=================================#
#*	 　check1to100	 *#
#=================================#
def check_dice(diff,min,max)
  diff = min if diff < min
  diff = max if diff > max
  return diff
end

#=================================#
#*	 　複雑な式の処理	 *#
#=================================#
  def calc(formula)
    formula = formula.gsub(/[\+\-\*\/\%]$/,"")
    percent = $1.to_i if (/\%(\d+)/i =~ formula)
    formula = formula.gsub(/\%(\d+)/i,"")
    infix_array = formula_to_infix(formula)
    postfix_array = infix_to_postfix(infix_array)
    result = calc_postfix(postfix_array)
    result = result * percent / 100 if percent
    return result
  end

#=================================#
#*	数値と演算子の分別処理	 *#
#=================================#
  def formula_to_infix(formula)
    infix_array = Array.new
    sign = "" # 単項演算子の符号を覚えておく変数
    may_sign = true # 単項演算子の符号が現れる可能性があるときtrue
    s = StringScanner.new(formula)
    while !s.eos?
      case
      when s.scan(/(\*|\/|\(|\))/)
        # ×、／、左括弧と右括弧の場合
        infix_array << s[1]
        may_sign = true
      when s.scan(/(\+|\-)/)
        # ＋と－の場合
        if may_sign then
          sign = s[1]
        else
          infix_array << s[1]
        end
      when s.scan(/(\d+)/)
        # 符号のついていない数値が見つかった場合
        infix_array << sign + s[1]
        sign = ""
        may_sign = false
      else
        raise "error #{s.rest}"
      end
    end
    infix_array
  end

#=================================#
#*	 演算方法の置き換え      *#
#=================================#
  def infix_to_postfix(infix_array)
    output = Array.new
    ope_stack = Array.new
    infix_array.each { |token|
      if token == '(' then
        ope_stack.push(token)
      elsif token == ')' then
        while ope_stack.size > 0 do
          ope = ope_stack.pop
          break if ope == '('
          output << ope
        end
      elsif '*|/'.split('|').include?(token) then
        while ope_stack.size > 0 && '*|/'.split('|').include?(ope_stack.last) do
          ope = ope_stack.pop
          output << ope
        end
        ope_stack.push(token)
      elsif '+|-'.split('|').include?(token) then
        while ope_stack.size > 0 && '+|-|*|/'.split('|').include?(ope_stack.last) do
          ope = ope_stack.pop
          output << ope
        end
        ope_stack.push(token)
      elsif /(\-{0,1}\d+)/ =~ token then
        output << token
      else
        printf "LINE#{__LINE__}: token error [#{token}] \n"
        raise "error #{token}"
      end
    }
    while ope_stack.size > 0 do
      output << ope_stack.pop
    end
    output
  end

  def calc_postfix(postfix_array)
    stack = Array.new
    postfix_array.each { |token|
      case token
      when "+" then 
        r = stack.pop
        l = stack.pop
        stack.push(l + r)
      when "-" then 
        r = stack.pop
        l = stack.pop
        stack.push(l - r)
      when "*" then 
        r = stack.pop
        l = stack.pop
        stack.push(l * r)
      when "/" then 
        r = stack.pop
        l = stack.pop
        if r != 0 then
          stack.push(l / r)
        else
          p postfix_array
          return "divided by zero"
        end
      else
        stack.push(token.to_i)
      end
    }
    result = stack.pop
  end

  def tnp(command)
    per = rand(979982)+1
    size_table = [0,3,27,188,1048,4718,17205,51070,124282,250446,423749,613506,779125,894349,958248,966495,976448,979244,979870,979982]
    for i in 1..19 do
      if( size_table[i-1] < per && per <= size_table[i] )
        return "#{i+3}cm"
      end
    end
    return "ERROR:TNP"
  end

#=================================#
#*	 　EXコマンド		 *#
#=================================#
  def ex_command(command)
    if(/\[TESTFOR\]/)
      return "TESTFOR EX COMMAND"

    # シグナル用SANチェック
    elsif( /\[SANC(\d+),([1-5]),([1-5])\]/ =~ command )
      diff    = $1.to_i
      insan1  = $2.to_i-1
      insan2  = $3.to_i-1
      success = ["1D6", "1D8", "1D10",  "2D6", "2D8", "2D10"]
      failure = ["1D10","1D12","1D12+1","2D10","2D12","2D12+1"]
      total_n = noDice(@min_dice,@max_dice)
      if( total_n <= 5 )
        damage_dice = success[insan1] + "+" + insan2.to_s
        if( /(\d+)D(\d+)(\+\d+)?/ =~ success[insan1] )
          damage = calc_dice("#{$1}+#{insan2}#{$3}")
        end
        result = "決定的成功"
      elsif( total_n >= 96 )
        damage_dice = failure[insan1] + "+" + insan2.to_s
        if( /(\d+)D(\d+)(\+\d+)?/ =~ failure[insan1] )
          damage = calc_dice("#{$2}*#{$1}+#{insan2}#{$3}")
        end
        result = "致命的失敗"
      elsif( total_n <= diff )
        damage_dice = success[insan1] + "+" + insan2.to_s
        damage = calc_dice(damage_dice)
        result = "成功"
      else
        damage_dice = failure[insan1] + "+" + insan2.to_s
        damage = calc_dice(damage_dice)
        result = "失敗"
      end
      return "(CCB#{diff}) ＞ #{total_n} ＞ #{result}\n              SAN減少#{damage_dice.gsub(/\+0/,"")} ＞ #{damage}"

    elsif( /\[(.*)\]/i =~ command)
      txt = $1.split(/\[|\]/)				#[]で区切る。この段階で単純なダイスはロールされる
      for i in 0..txt.length-1 do			  #タグにヒットするものを探索
        if( /([D\d+\+\-\*\/]+:.+)/i =~ txt[i] )		    #[nDx:A,B,C･･･]形式のタグ
          table_txt = $1.split(":")			    #タグの情報を取り出す、なぜかこれじゃないと動かない
          table = table_txt[1].split(",")		    #配列部分をちゃんと配列にする
          number = calc_dice(table_txt[0])		    #ダイスの結果
          if( number < 1 )				    #配列なので1以下は1、配列の長さ以上は最後に強制
            number = 1					      #
          elsif( number > table.length )		    #
            number = table.length			      #
          end						    #
          if( /(\d+D\d+)/i =~ table[number-1] )		    #配列の中がさらにダイスの場合
            txt[i] = calc_dice(table[number-1])		      #配列の中のダイスを計算してTXTの中を置き換え
          else						    #それ以外ならそのまま
            txt[i] = table[number-1]			      #
          end						    #
        elsif( /([D\d+]+\+[D\d+\+\-\*\/]+)/i =~ txt[i] )  #ただのnDxは勝手に処理するのにnDx含んだ計算式はされないので頑張る
          number = calc_dice($1)			    #
          txt[i] = "#{number}"				    #
        end						  #
      end						#
      output = "#{txt.join("")}"			#joinは確認用、普段は""でいい
      return "#{output}"			      #
    end						    #
    return nil					    #
  end						  #
  
  def calc_dice(str)
    dice  = str.split(/(\+|\-|\*|\/)/)	
    for j in 0 .. dice.length-1 do
      if( /(\d+)D(\d+)/i =~ dice[j])
        dice[j] = roll2($1.to_i,$2.to_i,0)
      elsif( /D66/i =~ dice[j])
        dice[j] = roll2(1,6,0)*10+roll2(1,6,0)
      end
    end
    number = calc(dice.join(""))
    return number
  end

  def roll2(n,x,a)
    result = 0
    for i in 1 .. n
      result += noDice(1,x)
    end
    result += a
    return result
  end

end