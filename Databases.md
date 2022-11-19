# Database Types
Databases come in three forms:
- Binary: A blob of data useful to the driver. Can be decompiled to a textdump. **NOTE**: Binary databases are specific to the version of Genesis that created them. Always decompile to a textdump before updating Genesis.
- Textdump: A human readable version of the database, similar to a MOO database but friendlier. Can be converted into a binary database.
- Source: A collection of .cdc files that can later be merged back into a textdump.

# Database Directory Contents
| Directory  | Function                                                                                                                              |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Backups    | Stores binary database backups.                                                                                                       |
| Bin        | Contains `coldcc` and Genesis executables.                                                                                            |
| Binary     | The binary database. **CAN ONLY BE ACCESSED BY THE VERSION OF COLDCC THAT CREATED IT! ALWAYS DECOMPILE TO TEXTDUMP WHEN UPGRADING! ** |
| Binary.bak | The most recent backup of the binary database created by `backup()`                                                                   |
| Dbbin      | Files that can be executed from inside the database. (**NOTE: Edit the backup script with the *full path* of your database.**)        |
| Logs       | Server log files.                                                                                                                     |
| Root       | This is akin to the MOO 'files' directory. It's the only directory files can go with `RESTRICTIVE_FILES` enabled.                     |
| Src        | Individual source files split from a textdump by `dumpsplit`                                                                          |
| Textdump   | The database in a human readable flat text file.                                                                                      |

# Commands
| Command                                   | Function                                                                                                                                 |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `./bin/coldcc -d`                         | Decompile a binary database into a textdump.                                                                                             |
| `./bin/coldcc -d -#`                      | Decompile a binary database **WITHOUT** object numbers. This forces a consolidation / renumber the next time you recompile the database. |
| `./bin/coldcc -c`                         | Recompile a textdump into a binary database.                                                                                             |
| `./bin/coldcc -f -p -t textdump.snapshot` | Save a snapshot of the current objects.                                                                                                  |
| `./bin/dumpsplit`                         | Split / unsplit a textdump into individual files. (Although I think you're supposed to use `tdjoin`.)                                    |
| `./bin/coldcc -tsdtin -p`                 | Emergency wiz mode, as it were. Possibly no feedback? See [emergency user reentrance](#emergency-user-reentrance) below.                 |

# Emergency User Reentrance
This is sort of an equivalent to emergency wizard mode. This command allows you to directly interface with the database without having to establish a network connection. This is not nearly as user friendly as MOO's emergency wizard mode. **WARNING**: The database should **NOT** be running when you do this.

- `coldcc -p -tstdin`
- Example eval:
```coldc
Eval {
  var u;
 
  for u in (user.children())
      $user_db.insert(u.name(), u);
}
```
- CTRL-D

# Creating a Textdump Backup Safely
- `;backup()` in the game (or @backup)
- `./bin/coldcc -d -b binary.bak -t textdump-DATE`
	- This will create a textdump from the backup binary database just created. Doing it this way ensures that changes occurring in the active server won't affect the textdump.
