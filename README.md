### Hi there 👋

from typing import Tuple

class Attributes(wuliLiuyue):
	@property
	def contact() -> Tuple[str, str]:
	    discord  = "wuliLiuyue"
	    telegram = "wuliLiuyue"
	    
	    return discord, telegram
	
	@property
	def life() -> Tuple[list, int]:
		langs         = ['Chinese', 'English']
		age           = 18
		
		return langs, age
	
	@property
	def coding() -> Tuple[dict, list, list]:
		langs = {
			'expert':   ['js'],
			'intermediate': ['python', 'dart'],
			'learning': ['rust', 'c++', 'go']
		}
		specialities  = ['web/app reverse engineering', 'fullstack']
		environnement = ['cursor']
		
		return langs, specialities, environnement

![wuliLiuyue's GitHub stats](https://github-readme-stats.vercel.app/api?username=wuliLiuyue&count_private=true&show_icons=true)

[![Top Langs](https://github-readme-stats.vercel.app/api/top-langs/?username=wuliLiuyue)](https://github.com/wuliLiuyue/wuliLiuyue)
