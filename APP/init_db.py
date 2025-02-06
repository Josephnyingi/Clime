from database import Base, engine

# Create the tables
Base.metadata.create_all(bind=engine)

print("Database tables created successfully!")
