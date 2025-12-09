# Agent Guidelines for our-story

## Project Structure
Spring Boot 3.5.7 backend (Java 21) with PostgreSQL in `our-story-back/`
Flutter frontend in `our_story_front/`

## Build/Test Commands
### Backend
- Build: `cd our-story-back && ./mvnw clean install`
- Run: `cd our-story-back && ./mvnw spring-boot:run`
- Test all: `cd our-story-back && ./mvnw test`
- Test single: `cd our-story-back && ./mvnw test -Dtest=ClassName#methodName`
- Database: `cd our-story-back && docker-compose up -d`

### Frontend
- Run: `cd our_story_front && flutter run`
- Clean: `cd our_story_front && flutter clean`
- Build: `cd our_story_front && flutter build apk`
- Update IP after reconnecting phone: `./update_ip.sh`

## Mobile Connection Setup
When reconnecting phone via USB, the IP address changes. Use the script to auto-detect and update:
```bash
./update_ip.sh  # Auto-detects IP and updates api_constants.dart
```
See `IP_SETUP.md` for detailed instructions.

## Code Style
- Package: `com.ourstory.our_story_back` (snake_case for package name)
- Imports: Group Spring imports, then external libs, then internal packages
- Use Lombok annotations (@Data, @Builder, etc.) to reduce boilerplate
- JPA entities in separate package, use camelCase for Java, snake_case for DB columns
- REST endpoints under `/api` context path
- Use JUnit 5 (@Test) and @SpringBootTest for integration tests
- Error handling: Use Spring's @ControllerAdvice for global exception handling
- Naming: Services end with Service, Controllers with Controller, Repos with Repository
- Configuration: Use application.properties, avoid hardcoded values
