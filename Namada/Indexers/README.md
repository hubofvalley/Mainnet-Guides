# Namada Indexer Snapshot Service Guide

Snapshots are provided by **Grand Valley for the Namada Community**. The snapshot service updates (rotates) the snapshots once a day at **2AM UTC**. The snapshot file names are static—each new snapshot overwrites the previous one.

## Snapshot File Names

- **Namada Indexer Snapshot:** `indexer_snapshot.sql`
- **MASP Indexer Snapshot:** `masp_indexer_snapshot.sql`

## Tested Snapshot Versions

- **Namada Indexer Snapshot:**  
  The current snapshot has been tested and applied to the Namada indexer corresponding to commit  
  `5d1a8d4b3a1a879caafc0348a5ae25c63037f02c` (HEAD, tag: `v3.3.4`).

- **MASP Indexer Snapshot:**  
  The current snapshot has been tested and applied to the MASP indexer corresponding to commit  
  `658feb55efb04089f849ab40609bebc0c835f180` (HEAD, tag: `v1.3.0`, origin/master, origin/HEAD, master).

## How It Works

Every day at **2AM UTC** a new snapshot is generated. Since the file names remain static, the new snapshot automatically overwrites the old one. This approach simplifies the process of restoring or applying snapshots without needing to track dynamic file names.

## Instructions for Applying the Snapshot

### Namada Indexer Database Snapshot

1. **Switch to your namada-indexer directory:**

   ```bash
   cd $HOME/namada-indexer
   ```

2. **Download the snapshot:**

   ```bash
   wget -O indexer_snapshot.sql https://indexer-snapshot-mainnet-namada.grandvalleys.com/indexer_snapshot.sql
   ```

3. **Stop and remove the containers (and volumes):**

   ```bash
   docker compose down -v
   ```

4. **Start only the PostgreSQL container:**

   ```bash
   docker compose up -d postgres
   ```

5. **Copy the snapshot file into the container:**

   ```bash
   docker compose cp indexer_snapshot.sql postgres:/tmp/indexer_snapshot.sql
   ```

6. **Restore the database from the snapshot:**

   ```bash
   docker compose exec -u postgres postgres pg_restore -U postgres -d namada-indexer --clean /tmp/indexer_snapshot.sql --verbose
   ```

7. **Remove the snapshot file from the container:**

   ```bash
   docker compose exec postgres rm /tmp/indexer_snapshot.sql
   ```

8. **Bring up the remaining containers:**

   ```bash
   docker compose up -d
   ```

9. **Check the logs:**
   ```bash
   docker logs --tail 50 -f namada-indexer-transactions-1
   ```

### Namada MASP Indexer Database Snapshot

1. **Switch to your namada-masp-indexer directory:**

   ```bash
   cd $HOME/namada-masp-indexer
   ```

2. **Download the snapshot:**

   ```bash
   wget -O masp_indexer_snapshot.sql https://masp-indexer-snapshot-mainnet-namada.grandvalleys.com/masp_indexer_snapshot.sql
   ```

3. **Stop the containers:**

   ```bash
   docker compose down
   ```

4. **Start only the PostgreSQL container:**

   ```bash
   docker compose up -d postgres
   ```

5. **Copy the snapshot file into the container:**

   ```bash
   docker compose cp masp_indexer_snapshot.sql postgres:/tmp/masp_indexer_snapshot.sql
   ```

6. **Restore the database from the snapshot:**

   ```bash
   docker compose exec postgres pg_restore -d masp_indexer_local --clean /tmp/masp_indexer_snapshot.sql --verbose
   ```

7. **Remove the snapshot file from the container:**

   ```bash
   docker compose exec postgres rm /tmp/masp_indexer_snapshot.sql
   ```

8. **Bring up the remaining containers:**

   ```bash
   docker compose up -d
   ```

9. **Check the logs:**
   ```bash
   docker logs --tail 50 -f namada-masp-indexer-crawler-1
   ```

## Notes

- Ensure your environment is properly set up with Docker and Docker Compose.
- The snapshot service is maintained by Grand Valley for the Namada Community.
- For further support or issues, please refer to the community forums or contact the maintainers.

### Let's Buidl Namada Together
