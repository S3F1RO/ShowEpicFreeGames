#Imports
import discord
import requests
from datetime import *
from discord.ext import tasks
import os
from dotenv import load_dotenv

#Bot Initialisation
load_dotenv()
token = os.getenv("DISCORD_TOKEN")
bot = discord.Client(intents=discord.Intents.all())
CHANNEL_ID=int(os.getenv("CHANNEL_ID"))
#Date Checking (if thursday [date of Epic])
@tasks.loop(hours=24)
async def sendFreeEpicGames():
    channel = bot.get_channel(CHANNEL_ID)
    today = date.today()
    nextWeek = today + timedelta(days=7)
    if today.weekday() == 4 :
        #Link for promotions
        epic ="https://store-site-backend-static.ak.epicgames.com/freeGamesPromotions?locale=en-FR&country=FR&allowCountries=FR"
        response = requests.get(epic, timeout=10)
        #Get jsonData from link
        data = response.json()
        #Check each elements 
        await channel.purge(limit=10)
        for i in (data['data']['Catalog']['searchStore']['elements']):
            #Check if the game is free
            if (i['price']['totalPrice']['discountPrice'] == 0):
                #Check if the title in the URL is None
                if (i['catalogNs']['mappings'] is None): 
                    urlSlug = i['catalogNs']['mappings'][0]['pageSlug']
                elif (i['productSlug']):
                    urlSlug = i['productSlug']
                else:    
                    urlSlug = i['urlSlug']
                
                #Check if there is a url to send if none don't send
                if (urlSlug == "[]" or urlSlug is None):
                    pass
                else:
                    url="https://store.epicgames.com/fr/p/" + urlSlug
                    if channel:
                        await channel.send(
                            f"🎮 {i['title']} est gratuit jusqu'au {nextWeek} les gaaaaars !!!!\n"
                            f"🌐 Lien pour le télécharger : {url}\n\n"    
                        )   
                    else: 
                        print("Channel not found")

@bot.event
async def on_ready():
    print(f"Logged in as {bot.user}")
    sendFreeEpicGames.start()  # start the loop

if __name__ == '__main__':
    bot.run(token=token)
