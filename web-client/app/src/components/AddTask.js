import React, { useRef } from 'react'
import styles from './AddTask.module.css'

export default function AddTask({ addTask }) {
  const inputEl = useRef(null)

  return (
    <div>
      <form className={styles.addTask} onSubmit={e => {
        e.preventDefault()
        if (!inputEl.current.value.trim()) {
          return
        }
        addTask(inputEl.current.value)
        inputEl.current.value = ''
      }}>
        <input className={styles.titleText} placeholder='タイトル' ref={inputEl} />
        <button className={styles.addButton} type='submit'>
          Add Task
        </button>
      </form>
    </div>
  )
}
