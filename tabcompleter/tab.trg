import java.io.File
import java.io.FileInputStream
import java.io.BufferedReader
import java.io.InputStreamReader
IMPORT java.lang.Character
IMPORT java.util.Base64
IMPORT org.bukkit.Bukkit
IMPORT org.bukkit.configuration.file.YamlConfiguration
IMPORT io.github.wysohn.triggerreactor.core.main.TriggerReactorCore

plugin = TriggerReactorCore.getInstance()
commandTrigger = plugin.getCmdManager()
customTrigger = plugin.getCustomManager()
trTabcomplete = customTrigger.get("TR-Tabcomplete")



directory = File("./plugins/TriggerReactor/CommandTrigger")
cmdlist = list()
FOR f = directory.listFiles()
	f = f.toString()
	f = f.replace(".\\plugins\\TriggerReactor\\CommandTrigger\\", "")
	IF f.contains("trg")
		f = f.replace(".trg" ,"")
		cmdlist.add(f)
	ENDIF
ENDFOR
scriptlist = list()
script = "msg = event.getBuffer()\r\nmsg = msg.replace(\"/\", \"\")\r\nmsg = msg.split(\" \")\r\namsg = msg[0]\r\nplayer = event.getSender()\r\ntablist = list()\r\ntablist2 = list()\r\n"
FOR i = 0:cmdlist.size()
name = cmdlist.get(i)
file = File("./plugins/TriggerReactor/CommandTrigger/"+name+".trg")
filereader = FileInputStream(file)
input = InputStreamReader(filereader, "UTF-8")
bufreader = BufferedReader(input)
argslist = list()
value = list()
	WHILE true
		scan = bufreader.readLine()
		IF scan == null
			#BREAK
		ELSE
			IF scan.contains("IF args[") || scan.contains("&& args[") || scan.contains("|| args[")
				scan = scan.replaceAll("IF " ,"")
				scan = scan.replaceAll("ELSE" ,"")
				scan = scan.replaceAll("ENDIF" ,"")
				scan = scan.replaceAll("\"" ,"")
				scan = scan.replaceAll("	" ,"")
				sin = scan.indexOf("args[")
				sam = scan.substring(sin,scan.length())
				fd = sam.indexOf("[")
				IF Character.isDigit(sam.charAt(fd+1))
					sam = sam.replaceAll("\\)","")
					sam = sam.replaceAll("\\(","")
					IF sam.contains("&&") || sam.contains("||")
						IF sam.contains("&&")
							samd = sam.split("&&")
								FOR i = 0:samd.length 
									IF samd[i].contains("args[")
										IF Character.isDigit(sam.charAt(fd+1))
											argslist.add(sam.charAt(fd+1))
										ENDIF
										string = samd[i].toString().substring(11, samd[i].length())
										string = string.replace(" ","")
										value.add(string)
									ENDIF
								ENDFOR					
						ENDIF
						IF sam.contains("||")
							samd = sam.split("||")
								FOR i = 0:samd.length 
									IF samd[i].contains("args[")
										IF Character.isDigit(sam.charAt(fd+1))
											argslist.add(sam.charAt(fd+1))
										ENDIF
										string = samd[i].toString().substring(11, samd[i].length())
										string = string.replace(" ","")
										value.add(string)
									ENDIF
								ENDFOR							
						ENDIF
					ELSE
						IF Character.isDigit(sam.charAt(fd+1))
							argslist.add(sam.charAt(fd+1))
						ENDIF
						string = sam.substring(11, sam.length())
						string = string.replace(" ","")
						value.add(string)
					ENDIF
					ENDIF
				ENDIF
				IF script == ""
					script = scan
				ELSE
				ENDIF
			ENDIF
		ENDIF
		
	ENDWHILE
	va = value
	args = argslist
	IF value.size() != 0
	value = value.toString()
	value = value.substring(1, value.length())
	value = value.replace("]" , "")
	argslist = argslist.toString()
	argslist = argslist.substring(1, argslist.length())
	argslist = argslist.replace("]" ,"")
	script = script+""+name+"list = \""+value+"\"\r\n"+name+"args = \""+argslist+"\"\r\n"+name+"argslist = list()\r\n"+name+"valuelist = list()\r\n"+name+"args = "+name+"args.split(\",\")\r\n"+name+"value = "+name+"list.split(\",\")\r\nFOR i = 0:"+name+"args.length\r\n"+name+"argslist.add("+name+"args[i])\r\nENDFOR\r\nFOR i = 0:"+name+"value.length\r\n"+name+"valuelist.add("+name+"value[i])\r\nENDFOR\r\n"
	FOR i = 0:args.size()
		IF a == null
			a = args.get(i)
			a = parseInt(a.toString())
		ELSE
			b = args.get(i)
			b = parseInt(b.toString())
			IF b > a
				a = b
			ENDIF		
		ENDIF
	ENDFOR
	FOR a = 1:b+2
		script = script+"IF amsg == \""+name+"\"\r\n	IF msg.length > "+a+"\r\n"
				FOR d = 0:va.size()
					IF parseInt(args.get(d).toString()) == a - 1
											var = va.get(d)
						IF !script.contains("var"+var)
						script = script+" var"+va.get(d)+" = \""+va.get(d)+"\"\r\n"
						ENDIF
					ENDIF
				ENDFOR
				FOR h = 0:va.size()
					IF parseInt(args.get(h).toString()) == a - 1
						fg = a - 1
						var = va.get(h)
						IF !script.contains("IF var"+var)
						script = script+"IF var"+va.get(h)+".contains(msg["+a+"])\r\ntablist.add(\""+va.get(h)+"\")\r\nevent.setCompletions(tablist)\r\nENDIF\r\n"
						ENDIF
					ENDIF
				ENDFOR
			script = script + "ELSE\r\n"
				FOR s = 0:va.size()
				
					IF parseInt(args.get(s).toString()) == a - 1
					IF !script.contains("tablist2.add(\""+va.get(s)+"\")")
						script = script+"tablist2.add(\""+va.get(s)+"\")\r\n"
					ENDIF
					ENDIF
				ENDFOR
		script = script+"event.setCompletions(tablist2)\r\nENDIF\r\nENDIF\r\n"
	ENDFOR
ENDIF
ENDFOR
	IF trTabcomplete == null
		Bukkit.getConsoleSender().sendMessage("[TR] CustomTrigger 생성중")
		customTrigger.createCustomTrigger("org.bukkit.event.server.TabCompleteEvent", "TR-Tabcomplete", script)
		plugin.saveAsynchronously(customTrigger)
		trTabcomplete = customTrigger.get("TR-Tabcomplete")
		trTabcomplete.setSync(true);
		plugin.saveAsynchronously(customTrigger)
		Bukkit.getConsoleSender().sendMessage("[TR] CustomTrigger 생성완료")
	ELSE
		customTrigger.get("TR-Tabcomplete").setScript(script)
		plugin.saveAsynchronously(customTrigger)
	ENDIF
