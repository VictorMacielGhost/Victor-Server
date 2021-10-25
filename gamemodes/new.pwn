// ----------------------------------- Includes utilizadas no servidor ------------------ //
#include <a_samp>
#include <ZCMD>
#include <DOF2>
#include <sscanf2>
// ---------------------------------- FIM das includes --------------------------------- //

//--------------------------------- Enums Do servidor -----------------------------//
enum Horas // Enum para salvar as horas do inicio do servidor, pode ser utilizado em outros locais normalmente
{
	Hora,
	Minuto,
	Segundo
};

enum Data // enum utilizada para salvar o dia mes e ano que foi ligado o servidor, pode ser utilizado normalmente em outros locais
{
	Dia,
	Ano,
	Mes
};

// -------------------------------- fim das enums do servidor ----------------------- //


//--------------------------------- Variaveis Do tipo GLOBAL ----------------------//
new HoraLigadoOuDesligado[Horas];
new Dias[Data];
new bool:PlayerLogado[MAX_PLAYERS] = false;
new NomeOrg[MAX_PLAYERS][64];
new NomeCargo[MAX_PLAYERS][64];

// ------------ variaveis relacionada a conta de players


enum pInfo
{
	OrgNome,
	Cargo,
	Dinheiro,
	Skin,
	Score,
	Cor[8],
	NivelProcurado
};

new PlayerInfo[MAX_PLAYERS][pInfo];

// -------------------------------- FIM das variaveis GLOBAIS ----------------------//





main()
{

	gettime(HoraLigadoOuDesligado[Hora], HoraLigadoOuDesligado[Minuto], HoraLigadoOuDesligado[Segundo]);
	getdate(Dias[Ano], Dias[Mes], Dias[Dia]);

	print("-----------------------------------------------------------------");
	print("| --> Breaking Peace");
	print("| --> Servidor inicializado com sucesso");
	printf("| --> Servidor Inicializado às %d horas, %d minutos e %d segundos" , HoraLigadoOuDesligado[Hora], HoraLigadoOuDesligado[Minuto], HoraLigadoOuDesligado[Segundo]);
	printf("| --> Inicializado dia %d/%d de %d", Dias[Dia], Dias[Mes], Dias[Ano]);
	print("-----------------------------------------------------------------");
	
}

public OnGameModeInit()
{
	SetGameModeText(" ----------- "); // altere conforme o gosto
	DisableInteriorEnterExits(); // Desabilitar interiores entráveis, comente caso queira desativar
	UsePlayerPedAnims(); // Utilizar funções de corrida / andar do CJ, comente para desativar
	EnableStuntBonusForAll(0); // desabilitar bonus por saltos insanos, comente para habilitar


	return 1;
}

public OnGameModeExit()
{
	gettime(HoraLigadoOuDesligado[Hora], HoraLigadoOuDesligado[Minuto], HoraLigadoOuDesligado[Segundo]);
	getdate(Dias[Ano], Dias[Mes], Dias[Dia]);

	printf(" Servidor desligado às %d horas, %d minutos e %d segundos" , HoraLigadoOuDesligado[Hora], HoraLigadoOuDesligado[Minuto], HoraLigadoOuDesligado[Segundo]);
	printf(" Desligado dia %d/%d de %d", Dias[Dia], Dias[Mes], Dias[Ano]);

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

	return 1;
}

public OnIncomingConnection(playerid, ip_address[], port)
{
	printf("Player ID %d esta tentando se conectar ao servidor (IP : %s, Porta : %d)", playerid, ip_address, port);
	return 1;
}

public OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 1);
	TogglePlayerSpectating(playerid, 0);
	SetSpawnInfo(playerid, -1, 26, -2657.4839, 632.3875, 14.4531, 180.3573, 0, 0, 0, 0, 0, 0);

	InterpolateCameraPos(playerid, -2711.398681, 568.333312, 29.153371, -2609.960449, 572.009582, 29.153371, 10000);
	InterpolateCameraLookAt(playerid, -2708.927490, 572.486511, 27.871107, -2613.088378, 575.641418, 27.730033, 10000);

	new StringContas[60], StringDialog[256];
	format(StringContas, sizeof StringContas, "Contas/%s.ini", pName(playerid));
	if(!DOF2_FileExists(StringContas))
	{
		format(StringDialog, sizeof StringDialog, "{FFFFFF}Conta {FF0000}%s{FFFFFF}: Não registrada\nDigite Uma Senha Para Se Registrar", pName(playerid));
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_PASSWORD, "Registro", StringDialog, "Registrar", "Sair");
	}
	else
	{
		format(StringDialog, sizeof StringDialog, "{FFFFFF}Conta {00FF00}%s{FFFFFF}: Está Registrada\nDigite Uma Senha Para Logar", pName(playerid));
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", StringDialog, "Logar", "Sair");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// salvando o player e resetando variaveis
	new StringConta[80];
	format(StringConta, sizeof StringConta, "Contas/%s.ini", pName(playerid));
	DOF2_SetInt(StringConta, "Skin", GetPlayerSkin(playerid));
	DOF2_SetInt(StringConta, "Score", GetPlayerScore(playerid));
	DOF2_SetInt(StringConta, "Dinheiro", GetPlayerMoney(playerid));
	DOF2_SetInt(StringConta, "NivelProcurado", GetPlayerWantedLevel(playerid)); // Caso nao funcione, recomendo uso de variavel, essa funcao pode  nao funcionar muito bem em certos APKS
	DOF2_SetInt(StringConta, "Organizacao", PlayerInfo[playerid][OrgNome]);
	DOF2_SetString(StringConta, "CorNome", "0xFFFFFFF");
	DOF2_SetInt(StringConta, "Cargo", PlayerInfo[playerid][Cargo]);
	DOF2_SaveFile();
	PlayerLogado[playerid] = false;

	
	

	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new String[256];
	if(PlayerLogado[playerid] == false)
	{
 		SendClientMessage(playerid, -1, "Voce ainda nao esta logado, ainda nao pode falar");
		return 0;
	}

	if(IsPlayerAdmin(playerid))
	{
		format(String, sizeof String, "{9400D3}(Admin) %s {FFFFFF}Diz: %s", pName(playerid), text);
		SendClientMessageToAll(-1, String);
		return 0;
	}

	format(String, sizeof String, "(%s) %s %s Diz: %s", NomeOrg[playerid], NomeCargo[playerid], pName(playerid), text);
	SendClientMessageToAll(-1, String);

	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new logou[30];
	if(success)
	{
		logou = "Com Sucesso";
	}
	else
	{
		logou = "Sem Sucesso";
	}
	
	printf("IP %s Tentou se conectar na rcon %s Senha: [%s] ", ip, logou, password);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 0) // se for a dialog de registro
	{
		new StringConta[70], StringDialog[256];
		format(StringConta, sizeof StringConta, "Contas/%s.ini", pName(playerid));
		// formatando caminho 

		if(!response) // se cancelar registro
		{
			SendClientMessage(playerid, -1, "Você Cancelou o registro e foi kickado");
			Kick(playerid);
		}

		else // se o registro for sucess
		{
			DOF2_CreateFile(StringConta);
			DOF2_SetString(StringConta, "Senha", inputtext); 
			DOF2_SetInt(StringConta, "Skin", GetPlayerSkin(playerid));
			DOF2_SetInt(StringConta, "Score", GetPlayerScore(playerid));
			DOF2_SetInt(StringConta, "Dinheiro", GetPlayerMoney(playerid));
			DOF2_SetInt(StringConta, "NivelProcurado", GetPlayerWantedLevel(playerid)); // Caso nao funcione, recomendo uso de variavel, essa funcao pode  nao funcionar muito bem em certos APKS
			DOF2_SetInt(StringConta, "Organizacao", 0);
			DOF2_SetString(StringConta, "CorNome", "0xFFFFFFF");
			DOF2_SetInt(StringConta, "Cargo", 1);
			DOF2_SaveFile();

			format(StringDialog, sizeof StringDialog, "{FFFFFF}Conta {00FF00}%s{FFFFFF}: Está Registrada\nDigite Uma Senha Para Logar", pName(playerid));
			ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", StringDialog, "Logar", "Sair"); 

			TogglePlayerSpectating(playerid, 1);

		}

	}
	if(dialogid == 1) // se for a dialog de login
	{
		new StringConta[70];
		format(StringConta, sizeof StringConta, "Contas/%s.ini", pName(playerid));
		new Senha[64];
		format(Senha, sizeof Senha, "%s", DOF2_GetString(StringConta, "Senha"));

		// formatando caminho e senha correta

		if(!response) // se cancelar o login
		{
			SendClientMessage(playerid, -1, "Você Cancelou o login e foi kickado");
			Kick(playerid);
		}

		else // se ele prosseguir com o login
		{
			if(!strcmp(Senha, inputtext, false, 64)) // se acertar a senha
			{
				TogglePlayerSpectating(playerid, 0);
				SendClientMessage(playerid, -1, "Senha Correta! Você Foi Spawnado com sucesso");
				PlayerLogado[playerid] = true;
				PlayerInfo[playerid][OrgNome] = DOF2_GetInt(StringConta, "Organizacao");
				PlayerInfo[playerid][Cargo] = DOF2_GetInt(StringConta, "Cargo");
				PlayerInfo[playerid][Dinheiro] = DOF2_GetInt(StringConta, "Dinheiro");
				PlayerInfo[playerid][Skin] = DOF2_GetInt(StringConta, "Skin");
				PlayerInfo[playerid][Score] = DOF2_GetInt(StringConta, "Score");
				PlayerInfo[playerid][NivelProcurado] = DOF2_GetInt(StringConta, "NivelProcurado");
				format(PlayerInfo[playerid][Cor], sizeof StringConta, "%s", DOF2_GetString(StringConta, "CorNome"));


				Organizacao(playerid, PlayerInfo[playerid][OrgNome]);
				CargoNome(playerid, PlayerInfo[playerid][OrgNome], PlayerInfo[playerid][Cargo]);

			}

			else // se errar a senha
			{
				SendClientMessage(playerid, -1, "Senha errada, digite novamente");
				new StringDialog[256];

				format(StringDialog, sizeof StringDialog, "{FFFFFF}Conta {00FF00}%s{FFFFFF}: Está Registrada\nDigite Uma Senha Para Logar", pName(playerid));
				ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", StringDialog, "Logar", "Sair"); 
				TogglePlayerSpectating(playerid, 1);
			}

		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// ----------------------------- Comandos do servidor (ordem : Mais recentes primeiro) --------------------------------//
CMD:gmx(playerid)
{
	new StringGMX[60];
	if(IsPlayerAdmin(playerid))
	{
		printf("Admin %s ID [%d] deu GMX no servidor", pName(playerid), playerid);
		format(StringGMX, sizeof StringGMX, "Admin %s deu GMX No servidor", pName(playerid));
		SendClientMessageToAll(-1, StringGMX);
		SendClientMessageToAll(-1, "O Servidor Está reiniciando, não precisa sair, voltamos em alguns segundos. Aguarde...");
		GameTextForAll("~g~Reiniciando~n~~w~Desculpe o transtorno", 10000, 0);
		SendRconCommand("gmx");
	}
	return 1;
}

CMD:spawncarro(playerid, params[])
{
	new cor1, cor2, id, Float:X, Float:Y, Float:Z;
	if(IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ddd", id, cor1, cor2)) return SendClientMessage(playerid, -1, "Utilize /spawncarro ID, COR1, COR");
		GetPlayerPos(playerid, X, Y, Z);
		CreateVehicle(id, X, Y, Z, 0, cor1, cor2, -1, 0);
	}

	return 1;
}

// ------------------------------------ stocks do servidor (ordem : mais recentes primeiro) -----------------------------//


stock pName(playerid)
{
	new Nome[24];
	GetPlayerName(playerid, Nome, sizeof Nome);
	return Nome;

}

stock Organizacao(playerid, OrgID)
{
	if(OrgID == 0)
	{
		NomeOrg[playerid] = "Neutro";
	}

	else if(OrgID == 1)
	{
		NomeOrg[playerid] = "Bloods";
	}

	return NomeOrg[playerid];
}

stock CargoNome(playerid, OrgID, CargoLVL)
{
	if(OrgID == 0)
	{
		if(CargoLVL == 1)
		{
			NomeCargo[playerid] = "Civil";
		}
	}

	else if(OrgID == 1)
	{
		if(CargoLVL == 1)
		{
			NomeCargo[playerid] = "Novato";
		}

		else if(CargoLVL == 2)
		{
			NomeCargo[playerid] = "Atirador";
		}

		else if(CargoLVL == 3)
		{
			NomeCargo[playerid] = "Veterano";
		}

		else if(CargoLVL == 4)
		{
			NomeCargo[playerid] = "Chefão";
		}
	}

	return NomeCargo[playerid];
}