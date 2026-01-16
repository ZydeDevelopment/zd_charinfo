# 🎮 zd_charinfo

**Modern character information script for FiveM**  
Displays player information in a clean ox_lib context menu with support for ESX & QB-Core frameworks.

---

## ✨ Features

- 📱 **Multi-Framework Support** - Works with ESX & QB-Core
- 🌍 **Multi-Language** - English, Czech, German, French, Spanish
- 📞 **Phone Script Integration** - Supports 8+ popular phone scripts
- 🎨 **Modern UI** - Clean ox_lib context menu with icons
- 📊 **Customizable Display** - Toggle any information on/off
- 🔔 **Discord Webhook** - Log command usage to Discord
- ⚡ **Optimized** - Lightweight and performant

---

## 📋 Information Display

- Character Name
- Date of Birth
- Player ID
- Job & Grade
- Bank Money
- Cash Money
- Phone Number
- Citizen ID (QB-Core)
- Gang (QB-Core)
- Hunger Level
- Thirst Level

---

## 📦 Installation

1. Download and extract `zd_charinfo` to your resources folder
2. Add `ensure zd_charinfo` to your `server.cfg`
3. Configure `config.lua` to your needs
4. Restart your server

---

## ⚙️ Configuration

```lua
Config.Framework = 'esx' -- 'esx' or 'qb'
Config.Locale = 'en' -- cs, de, fr, en, es
Config.Command = 'id' -- Command to use
Config.PhoneScript = 'default' -- See supported phone scripts below
```

### 📞 Supported Phone Scripts

- `default` - Uses database phone_number column
- `gcphone`
- `d-phone` / `d_phone`
- `qs-smartphone`
- `qb-phone`
- `lb-phone`
- `yflip-phone`
- `okokPhone`
- `high_phone`

---

## 🔧 Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- ESX Legacy or QB-Core

---

## 🎯 Usage

Simply type `/id` in-game (or your configured command) to view your character information.

---

## 🌐 Languages

- 🇬🇧 English
- 🇨🇿 Czech
- 🇩🇪 German
- 🇫🇷 French
- 🇪🇸 Spanish

---

## 📝 License

This script is **free** and open for everyone to use.

---

## 👨‍💻 Developer

**ZydeDevelopment**

---

## 🐛 Support

For issues or questions, please open a ticket on our [DISCORD](https://discord.gg/cQSmd3hRt6)

---
## PREVIEW
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/1dbf7fc2-ed29-4d0a-bdcd-99ef973c2689" />


---

**Enjoy! 🚀**


