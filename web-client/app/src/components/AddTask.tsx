import React, { useRef } from 'react'
import styles from './AddTask.module.css'

type Props = {
  addTask: (string) => void
}

const AddTask: React.FC<Props> = ({ addTask }: Props) => {
  const inputEl = useRef<HTMLInputElement>(null)

  return (
    <div>
      <form
        className={styles.addTask}
        onSubmit={e => {
          e.preventDefault()
          if (!inputEl.current.value.trim()) {
            return
          }
          addTask(inputEl.current.value)
          inputEl.current.value = ''
        }}
      >
        <input
          className={styles.titleText}
          placeholder="タイトル"
          ref={inputEl}
        />
        <button className={styles.addButton} type="submit">
          Add Task
        </button>
      </form>
    </div>
  )
}

export default AddTask
