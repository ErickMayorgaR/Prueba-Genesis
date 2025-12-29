import { useState, useRef, useEffect } from 'react';
import { llmService } from '../services/api';
import { Card, Button, Spinner } from '../components/ui';
import { Send, Bot, User, Sparkles, BarChart3, Gift } from 'lucide-react';
import toast from 'react-hot-toast';

interface Mensaje {
  id: string;
  tipo: 'user' | 'assistant';
  contenido: string;
  timestamp: Date;
}

export default function Asistente() {
  const [mensajes, setMensajes] = useState<Mensaje[]>([
    {
      id: '1',
      tipo: 'assistant',
      contenido: '¡Hola! Soy el asistente virtual de La Cazuela Chapina 🫔\n\nPuedo ayudarte con:\n• Información sobre nuestros productos\n• Recomendaciones de combos\n• Análisis de ventas\n• Cualquier pregunta sobre el negocio\n\n¿En qué puedo ayudarte hoy?',
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [mensajes]);

  const enviarMensaje = async () => {
    if (!input.trim() || loading) return;

    const mensajeUsuario: Mensaje = {
      id: crypto.randomUUID(),
      tipo: 'user',
      contenido: input,
      timestamp: new Date(),
    };

    setMensajes((prev) => [...prev, mensajeUsuario]);
    setInput('');
    setLoading(true);

    try {
      const response = await llmService.chat({ mensaje: input });

      const mensajeAsistente: Mensaje = {
        id: crypto.randomUUID(),
        tipo: 'assistant',
        contenido: response.exito
          ? response.respuesta
          : 'Lo siento, hubo un error al procesar tu mensaje. ¿Podés intentar de nuevo?',
        timestamp: new Date(),
      };

      setMensajes((prev) => [...prev, mensajeAsistente]);
    } catch (error) {
      toast.error('Error al comunicarse con el asistente');
      const mensajeError: Mensaje = {
        id: crypto.randomUUID(),
        tipo: 'assistant',
        contenido: 'Lo siento, no pude conectarme. Verificá que el backend esté corriendo.',
        timestamp: new Date(),
      };
      setMensajes((prev) => [...prev, mensajeError]);
    } finally {
      setLoading(false);
    }
  };

  const sugerirCombo = async () => {
    setLoading(true);
    const mensajeUsuario: Mensaje = {
      id: crypto.randomUUID(),
      tipo: 'user',
      contenido: '¿Podrías sugerirme un combo para una reunión familiar de 10 personas?',
      timestamp: new Date(),
    };
    setMensajes((prev) => [...prev, mensajeUsuario]);

    try {
      const response = await llmService.sugerirCombo(
        'Reunión familiar de 10 personas, mezcla de adultos y niños, algunos no comen picante'
      );

      const mensajeAsistente: Mensaje = {
        id: crypto.randomUUID(),
        tipo: 'assistant',
        contenido: response.respuesta,
        timestamp: new Date(),
      };

      setMensajes((prev) => [...prev, mensajeAsistente]);
    } catch (error) {
      toast.error('Error al obtener sugerencia');
    } finally {
      setLoading(false);
    }
  };

  const analizarVentas = async () => {
    setLoading(true);
    const mensajeUsuario: Mensaje = {
      id: crypto.randomUUID(),
      tipo: 'user',
      contenido: '¿Puedes analizar las ventas actuales y darme insights?',
      timestamp: new Date(),
    };
    setMensajes((prev) => [...prev, mensajeUsuario]);

    try {
      const response = await llmService.analizarVentas();

      const mensajeAsistente: Mensaje = {
        id: crypto.randomUUID(),
        tipo: 'assistant',
        contenido: response.respuesta,
        timestamp: new Date(),
      };

      setMensajes((prev) => [...prev, mensajeAsistente]);
    } catch (error) {
      toast.error('Error al analizar ventas');
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      enviarMensaje();
    }
  };

  return (
    <div className="h-[calc(100vh-140px)] flex gap-6">
      {/* Panel de chat */}
      <div className="flex-1 flex flex-col bg-white rounded-xl border border-gray-200">
        {/* Header */}
        <div className="p-4 border-b border-gray-200 flex items-center gap-3">
          <div className="h-10 w-10 bg-amber-100 rounded-full flex items-center justify-center">
            <Bot className="h-5 w-5 text-amber-600" />
          </div>
          <div>
            <h2 className="font-semibold">Asistente IA</h2>
            <p className="text-sm text-gray-500">La Cazuela Chapina</p>
          </div>
        </div>

        {/* Mensajes */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {mensajes.map((mensaje) => (
            <div
              key={mensaje.id}
              className={`flex gap-3 ${
                mensaje.tipo === 'user' ? 'flex-row-reverse' : ''
              }`}
            >
              <div
                className={`h-8 w-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                  mensaje.tipo === 'user'
                    ? 'bg-blue-100'
                    : 'bg-amber-100'
                }`}
              >
                {mensaje.tipo === 'user' ? (
                  <User className="h-4 w-4 text-blue-600" />
                ) : (
                  <Bot className="h-4 w-4 text-amber-600" />
                )}
              </div>
              <div
                className={`max-w-[70%] p-3 rounded-xl ${
                  mensaje.tipo === 'user'
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-800'
                }`}
              >
                <p className="whitespace-pre-wrap text-sm">{mensaje.contenido}</p>
                <p
                  className={`text-xs mt-1 ${
                    mensaje.tipo === 'user' ? 'text-blue-200' : 'text-gray-400'
                  }`}
                >
                  {mensaje.timestamp.toLocaleTimeString('es-GT', {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </p>
              </div>
            </div>
          ))}

          {loading && (
            <div className="flex gap-3">
              <div className="h-8 w-8 bg-amber-100 rounded-full flex items-center justify-center">
                <Bot className="h-4 w-4 text-amber-600" />
              </div>
              <div className="bg-gray-100 rounded-xl p-3">
                <div className="flex gap-1">
                  <span className="h-2 w-2 bg-gray-400 rounded-full animate-bounce" />
                  <span className="h-2 w-2 bg-gray-400 rounded-full animate-bounce [animation-delay:0.2s]" />
                  <span className="h-2 w-2 bg-gray-400 rounded-full animate-bounce [animation-delay:0.4s]" />
                </div>
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="p-4 border-t border-gray-200">
          <div className="flex gap-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Escribe tu mensaje..."
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
              disabled={loading}
            />
            <Button onClick={enviarMensaje} disabled={!input.trim() || loading}>
              <Send className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Panel lateral - Acciones rápidas */}
      <div className="w-80 space-y-4">
        <Card title="Acciones Rápidas">
          <div className="space-y-3">
            <button
              onClick={sugerirCombo}
              disabled={loading}
              className="w-full flex items-center gap-3 p-3 rounded-lg bg-amber-50 hover:bg-amber-100 transition-colors text-left"
            >
              <Gift className="h-5 w-5 text-amber-600" />
              <div>
                <p className="font-medium text-sm">Sugerir Combo</p>
                <p className="text-xs text-gray-500">Para eventos o grupos</p>
              </div>
            </button>

            <button
              onClick={analizarVentas}
              disabled={loading}
              className="w-full flex items-center gap-3 p-3 rounded-lg bg-blue-50 hover:bg-blue-100 transition-colors text-left"
            >
              <BarChart3 className="h-5 w-5 text-blue-600" />
              <div>
                <p className="font-medium text-sm">Analizar Ventas</p>
                <p className="text-xs text-gray-500">Obtener insights del negocio</p>
              </div>
            </button>
          </div>
        </Card>

        <Card title="Ejemplos de Preguntas">
          <div className="space-y-2">
            {[
              '¿Cuáles son los tipos de masa disponibles?',
              '¿Qué incluye el Combo Fiesta Patronal?',
              '¿Cuál es el tamal más popular?',
              '¿Qué bebidas tienen para acompañar?',
            ].map((pregunta, index) => (
              <button
                key={index}
                onClick={() => setInput(pregunta)}
                className="w-full text-left p-2 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors text-sm text-gray-700"
              >
                {pregunta}
              </button>
            ))}
          </div>
        </Card>

        <Card>
          <div className="flex items-center gap-2 text-sm text-gray-500">
            <Sparkles className="h-4 w-4 text-amber-500" />
            <span>Powered by OpenRouter AI</span>
          </div>
        </Card>
      </div>
    </div>
  );
}
