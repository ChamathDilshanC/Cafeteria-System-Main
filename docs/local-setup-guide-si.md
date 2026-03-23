# ආපනශාලා පද්ධතිය — දේශීය සංවර්ධන මාර්ගෝපදේශය (Local Development Guide)

මෙම මාර්ගෝපදේශය මගින් Enterprise Cloud Architecture ව්‍යාපෘතිය ඔබගේ පරිගණකය තුළ ක්‍රියාත්මක කරන ආකාරය පෙන්වා දෙයි. මේ සඳහා දත්ත සමුදායන් (PostgreSQL සහ MongoDB) ක්‍රියාත්මක කිරීමට Docker ද, මයික්‍රොසර්විස් ක්‍රියාත්මක කිරීමට PM2/Maven ද භාවිතා කරයි.

## 1. අවශ්‍යතා (Prerequisites)

- **Docker සහ Docker Compose** (PostgreSQL සහ MongoDB සඳහා)
- **Java 25+** (Spring Boot මයික්‍රොසර්විස් ක්‍රියාත්මක කිරීම සඳහා)
- **Maven** (මයික්‍රොසර්විස් ගොඩනැගීම සඳහා)
- **Node.js** (Vue 3 ෆ්‍රන්ට්-එන්ඩ් වෙබ් යෙදුම සහ PM2 සඳහා)
- **PM2** (අත්‍යවශ්‍ය නොවේ, නමුත් පහසුව සඳහා නිර්දේශ කෙරේ. ස්තාපනයට `npm install -g pm2` භාවිතා කරන්න)

---

## 2. දත්ත සමුදායන් ක්‍රියාත්මක කිරීම (Docker හරහා)

අපගේ නව PostgreSQL සහ MongoDB දත්ත සමුදායන් පහසුවෙන්ම Docker හරහා ක්‍රියාත්මක කරගත හැක.

1. ව්‍යාපෘතියේ ප්‍රධාන ෆෝල්ඩරය හෙවත් `EnterpriseCloudArchitecture_Final` ඩිරෙක්ටරිය තුළ ඔබේ ටර්මිනලය (Terminal) විවෘත කරන්න.
2. පහත විධානය (command) ලබාදෙන්න:
   ```bash
   docker-compose up -d
   ```
3. **Containers ධාවනය වේ දැයි පරීක්ෂා කිරීම**:
   ```bash
   docker ps
   ```
   මෙහිදී `cafeteria-postgresql` (Port 5432) සහ `cafeteria-mongodb` (Port 27017) ක්‍රියාත්මක වන බවට තහවුරු කරගන්න.
   _(සටහන: PostgreSQL ක්‍රියාත්මක වීමේදී `init-scripts/postgresql/` හි ඇති ස්ක්‍රිප්ට් එක මගින් `menu_service_db`, `order_service_db`, සහ `user_service_db` යන දත්ත සමුදායන් ස්වයංක්‍රීයව නිර්මාණය වේ)._

---

## 3. Configuration Server සැකසීම

මයික්‍රොසර්විස් ක්‍රියාත්මක කිරීමට ප්‍රථම, ඔබගේ මධ්‍යගත සේවාදනයන් (configurations) ලබාගත හැකිදැයි තහවුරු කරගන්න.

1. ඔබ `platform/config-server/...` හි ඇති දත්ත ඔබගේ GitHub රිපොසිටරියට push කර ඇත්නම් Config Server ඒ හරහා දත්ත ලබාගනී.
2. අන්තර්ජාලය නොමැතිව ක්‍රියාත්මක කරන්නේ නම්, Config Server හි ඇති `native` fallback හරහා ස්වයංක්‍රීයව දත්ත ලබා ගනී.

---

## 4. මයික්‍රොසර්විස් කම්පයිල් කිරීම (Build)

ධාවනය කිරීමට ප්‍රථම සියලුම සර්විස් `.jar` ගොනු ලෙස ගොඩනගාගත යුතුය.

මෙම විධානය ප්‍රධාන ඩිරෙක්ටරිය තුළ ලබාදෙන්න:

```bash
mvn clean install -DskipTests
```

_(මෙමගින් Platform සහ Services කොටස්වල අදාළ `target/` ෆෝල්ඩර තුළ `.jar` ගොනු නිර්මාණය වේ)._

---

## 5. Backend මයික්‍රොසර්විස් ධාවනය කිරීම (අනිවාර්ය පිළිවෙල)

මයික්‍රොසර්විස් ක්‍රියාත්මක වීමේ පිළිවෙල අතිශය වැදගත් වේ. යැපෙන සේවාවන් බාධාවකින් තොරව ක්‍රියා කිරීමට නම් Config Server එක මුලින්ම ධාවනය විය යුතුය.

**PM2 භාවිතා කරන්නේ නම්:**

### පියවර 5.1: Platform සේවාවන් ධාවනය කිරීම

1. ප්‍රධාන ඩිරෙක්ටරිය මත හිඳිමින් පහත විධානය දෙන්න:
   ```bash
   pm2 start platform/ecosystem.config.js
   ```
2. **තත්පර 10-15ක් පමණ රැඳී සිටින්න.** `config-server` (Port 9000) සහ `service-registry` (Port 9001) සම්පූර්ණයෙන්ම ක්‍රියාත්මක වීමට කාලය ලබාදෙන්න.

### පියවර 5.2: Business සේවාවන් ධාවනය කිරීම

1. Platform සේවාවන් කියාත්මක වූ පසු, අනෙකුත් සේවාවන් ධාවනය කරන්න:
   ```bash
   pm2 start services/ecosystem.config.js
   ```
   (මෙමගින් `user-service`, `menu-service`, `order-service`, සහ `kitchen-service` එකින් දෙක බැගින් ධාවනය වේ).
2. සියලු සේවාවන් Eureka (`localhost:9001`) සහ Config Server (`localhost:9000`) සමඟ නිවැරදිව සම්බන්ධ වී ඇත්දැයි බැලීමට:
   ```bash
   pm2 logs
   ```

_(PM2 නොමැතිව ක්‍රියාත්මක කරන්නේ නම්, එක් එක් සේවාව වෙනම ටර්මිනල්වල `mvn spring-boot:run -Dspring-boot.run.profiles=dev` මගින් අනුපිළිවෙලට ධාවනය කරන්න)._

---

## 6. Eureka Service Registry පරීක්ෂා කිරීම

බ්‍රවුසරය (Browser) විවෘත කර පහත URL එක වෙත යන්න:

- **URL**: [http://localhost:9001](http://localhost:9001)

මෙහි `API-GATEWAY`, `USER-SERVICE`, `MENU-SERVICE`, `ORDER-SERVICE`, සහ `KITCHEN-SERVICE` නිවැරදිව ලියාපදිංචි වී ඇති බව ඔබට දැකගත හැකි වනු ඇත.

---

## 7. වෙබ් යෙදුම (Frontend) ධාවනය කිරීම

Backend සේවාවන් සියල්ල ධාවනය වන විට, පද්ධතිය භාවිතා කිරීමට වෙබ් යෙදුම ක්‍රියාත්මක කරන්න.

1. නව ටර්මිනලයක් විවෘත කර `webapp/` ෆෝල්ඩරයට යන්න:
   ```bash
   cd webapp
   ```
2. ඩිපෙන්ඩන්සි ස්තාපනය කර නොමැති නම්:
   ```bash
   npm install
   ```
3. Development සර්වරය ධාවනය කරන්න:
   ```bash
   npm run dev
   ```
4. දැන් බ්‍රවුසරයෙන් [http://localhost:3000](http://localhost:3000) වෙත පිවිසීමෙන් ව්‍යාපෘතිය අත්හදා බැලිය හැක. සියලුම API ඉල්ලීම් API Gateway එක (port 8080) හරහා ගමන් කරයි.

---

## 8. සියල්ල වසා දැමීම (Shutting Down)

තත්පර කිහිපයකින් මුළු පද්ධතියම වසා දැමීමට:

1. Frontend යෙදුම නවත්වන්න (වෙබ් ටර්මිනලය මත `Ctrl + C`).
2. සියලුම PM2 සේවාවන් නවත්වා, ඉවත් කරන්න:
   ```bash
   pm2 stop all
   pm2 delete all
   ```
3. Docker හරහා ක්‍රියාත්මක වන දත්ත සමුදායන් වසා දමන්න:
   ```bash
   docker-compose down
   ```
