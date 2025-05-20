# main.py
# Projeto: BRX - Inteligência Artificial Modular
# Desenvolvido por DragonSCP

from brx.core import BRXModel
from brx.config import MODEL_CONFIG

def main():
    print("=== Iniciando o modelo de IA BRX ===")
    
    # Instancia o modelo com base nas configurações
    model = BRXModel(MODEL_CONFIG)
    
    # Executa a lógica principal da IA
    model.run()

if __name__ == "__main__":
    main()
